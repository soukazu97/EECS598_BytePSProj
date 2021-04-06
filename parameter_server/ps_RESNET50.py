import argparse
import os
from threading import Lock
import time
import logging
import sys
from datetime import datetime

import torch
import torch.distributed.autograd as dist_autograd
import torch.distributed.rpc as rpc
import torch.multiprocessing as mp
import torch.nn as nn
import torch.nn.functional as F
from torch import optim
from torch.distributed.optim import DistributedOptimizer
from torchvision import datasets, transforms, models
from torch import optim

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)
logger = logging.getLogger()
def timed_log(text):
    print(f"{datetime.now().strftime('%H:%M:%S')} {text}")


# Constants
TRAINER_LOG_INTERVAL = 5  # How frequently to log information
TERMINATE_AT_ITER = 1e10  # for early stopping when debugging
PS_AVERAGE_EVERY_N = 25  # How often to average models between trainers

# --------- ResNet50 Network to train-----

# --------- Parameter Server --------------------
class ParameterServer(nn.Module):
    def __init__(self, num_gpus=0, world_size=0):
        super().__init__()
        self.num_gpus = num_gpus
        self.world_size = world_size
        self.model = models.resnet50()
        self.curr_update = 0
        self.future_model = torch.futures.Future()
        self.lock = Lock()
        self.optimizer = optim.SGD(self.model.parameters(), lr=0.03, momentum=0.9)
        for p in self.model.parameters():
            p.grad = torch.zeros_like(p)

    def get_model(self):
        return self.model

    @staticmethod
    @rpc.functions.async_execution
    def update_and_fetch_model(ps_rref, grads):
        # Using the RRef to retrieve the local PS instance
        self = ps_rref.local_value()
        with self.lock:
            self.curr_update += 1
            # accumulate gradients into .grad field
            for p, g in zip(self.model.parameters(), grads):
                p.grad += g

            # Save the current future_model and return it to make sure the
            # returned Future object holds the correct model even if another
            # thread modifies future_model before this thread returns.
            fut = self.future_model

            if self.curr_update >= self.world_size-1:
                # update the model
                for p in self.model.parameters():
                    p.grad /= (self.world_size-1)
                self.curr_update = 0
                self.optimizer.step()
                self.optimizer.zero_grad()
                # by setting the result on the Future object, all previous
                # requests expecting this updated model will be notified and
                # their responses will be sent accordingly.
                fut.set_result(self.model)
                self.future_model = torch.futures.Future()
        return fut

param_server = None
global_lock = Lock()
def get_parameter_server(rank, num_gpus=0, world_size=0):
    global param_server
    # Ensure that we get only one handle to the ParameterServer.
    with global_lock:
        if not param_server:
            # construct it once
            param_server = ParameterServer(num_gpus=num_gpus, world_size=world_size)
        # Add model for this rank
        # param_server.create_model_for_rank(rank, num_gpus)
        return param_server
            
def run_parameter_server(rank, world_size):
    # The parameter server just acts as a host for the model and responds to
    # requests from trainers, hence it does not need to run a loop.
    # rpc.shutdown() will wait for all workers to complete by default, which
    # in this case means that the parameter server will wait for all trainers
    # to complete, and then exit.
    logger.info("PS master initializing RPC")
    rpc.init_rpc(name="parameter_server", rank=rank, world_size=world_size)
    logger.info("RPC initialized! Running parameter server...")
    rpc.shutdown()
    logger.info("RPC shutdown on parameter server.")


# --------- Trainers --------------------
# nn.Module corresponding to the network trained by this trainer. The
# forward() method simply invokes the network on the given parameter
# server.
class Trainer(nn.Module):
    def __init__(self, rank, num_gpus=0, world_size=0):
        super().__init__()
        self.num_gpus = num_gpus
        self.rank = rank
        self.param_server_rref = rpc.remote(
            "parameter_server", get_parameter_server, args=(self.rank, num_gpus, world_size))
        device = torch.device("cuda:0" if num_gpus > 0
            and torch.cuda.is_available() else "cpu")
        self.model = self.param_server_rref.rpc_sync().get_model()
        self.model = self.model.to(device)

def run_training_loop(rank, world_size, num_gpus, train_loader, test_loader):
    # Runs the typical neural network forward + backward + optimizer step, but
    # in a distributed fashion.
    trainer = Trainer(rank=rank, num_gpus=num_gpus, world_size=world_size)
    name = rpc.get_worker_info().name
    device = torch.device("cuda:0" if num_gpus > 0
        and torch.cuda.is_available() else "cpu")
    # Build DistributedOptimizer.
    # param_rrefs = net.get_global_param_rrefs()
    logger.info(f"Number of batchs {len(train_loader)}")
    for i, (data, target) in enumerate(train_loader):
        if TERMINATE_AT_ITER is not None and i == TERMINATE_AT_ITER:
            break
        data = data.to(device)
        model_output = trainer.model(data)
        target = target.to(model_output.device)
        loss = F.nll_loss(model_output, target)
        if i % TRAINER_LOG_INTERVAL == 0:
            logger.info(f"Rank {rank} training batch {i} loss {loss.item()}")
        loss.backward()
        trainer.model = rpc.rpc_sync(
                trainer.param_server_rref.owner(),
                ParameterServer.update_and_fetch_model,
                args=(trainer.param_server_rref, [p.grad for p in trainer.model.cpu().parameters()]),
        )
        trainer.model = trainer.model.to(device)

        timed_log(f"{name} got updated model")
        # Ensure that dist autograd ran successfully and gradients were
        # returned.
        # assert net.param_server_rref.rpc_sync().get_dist_gradients(cid) != {}
        # opt.step(cid)

    logger.info("Training complete!")
    logger.info("Getting accuracy....")
    get_accuracy(test_loader, trainer.model)


def get_accuracy(test_loader, model):
    model.eval()
    correct_sum = 0
    # Use GPU to evaluate if possible
    device = torch.device("cuda:0" if model.num_gpus > 0
        and torch.cuda.is_available() else "cpu")
    with torch.no_grad():
        for i, (data, target) in enumerate(test_loader):
            data = data.to(device)
            out = model(data)
            pred = out.argmax(dim=1, keepdim=True)
            pred, target = pred.to(device), target.to(device)
            correct = pred.eq(target.view_as(pred)).sum().item()
            correct_sum += correct

    logger.info(f"Accuracy {correct_sum / len(test_loader.dataset)}")

# Main loop for trainers.
def run_worker(rank, world_size, num_gpus, train_loader, test_loader):
    logger.info(f"Worker rank {rank} initializing RPC")    
    rpc.init_rpc(
        name=f"trainer_{rank}",
        rank=rank,
        world_size=world_size)

    logger.info(f"Worker {rank} done initializing RPC")
    run_training_loop(rank, world_size, num_gpus, train_loader, test_loader)
    rpc.shutdown()

# --------- Launcher --------------------


if __name__ == '__main__':
    print("============>Torch version: ", torch.__version__)
    parser = argparse.ArgumentParser(
        description="Parameter-Server RPC based training")
    parser.add_argument(
        "--world_size",
        type=int,
        default=4,
        help="""Total number of participating processes. Should be the sum of
        master node and all training nodes.""")
    parser.add_argument(
        "--rank",
        type=int,
        default=None,
        help="Global rank of this process. Pass in 0 for master.")
    parser.add_argument(
        "--num_gpus",
        type=int,
        default=0,
        help="""Number of GPUs to use for training, currently supports between 0
         and 2 GPUs. Note that this argument will be passed to the parameter servers.""")
    parser.add_argument(
        "--master_addr",
        type=str,
        default="localhost",
        help="""Address of master, will default to localhost if not provided.
        Master must be able to accept network traffic on the address + port.""")
    parser.add_argument(
        "--master_port",
        type=str,
        default="29500",
        help="""Port that master is listening on, will default to 29500 if not
        provided. Master must be able to accept network traffic on the host and port.""")

    args = parser.parse_args()
    assert args.rank is not None, "must provide rank argument."
    assert args.num_gpus <= 3, f"Only 0-2 GPUs currently supported (got {args.num_gpus})."
    os.environ['MASTER_ADDR'] = args.master_addr
    os.environ['MASTER_PORT'] = args.master_port
    processes = []
    world_size = args.world_size
    
    dataset = datasets.CIFAR100('../data', train=True, download=True,
                            transform=transforms.Compose([
                             transforms.RandomResizedCrop(224),
                             transforms.RandomHorizontalFlip(),
                             transforms.ToTensor(),
                             transforms.Normalize(mean=[0.485, 0.456, 0.406],
                                                  std=[0.229, 0.224, 0.225])
                            ]))
    if(args.rank != 0):
        train_sampler = torch.utils.data.distributed.DistributedSampler(
            dataset,
            num_replicas=world_size-1,
            rank=args.rank-1
        )
    if args.rank == 0:
        p = mp.Process(target=run_parameter_server, args=(0, world_size))
        p.start()
        processes.append(p)
    else:
        # Get data to train on
        train_loader = torch.utils.data.DataLoader(dataset=dataset,batch_size=32, shuffle=False, sampler=train_sampler)
        test_loader = torch.utils.data.DataLoader(
            datasets.CIFAR100('../data', train=False,
                           transform=transforms.Compose([
                             transforms.Resize(256),
                             transforms.CenterCrop(224),
                             transforms.ToTensor(),
                             transforms.Normalize(mean=[0.485, 0.456, 0.406],
                                                  std=[0.229, 0.224, 0.225])
                           ])),
            batch_size=32, shuffle=True)
        # start training worker on this node
        p = mp.Process(
            target=run_worker,
            args=(
                args.rank,
                world_size, args.num_gpus,
                train_loader,
                test_loader))
        p.start()
        processes.append(p)

    for p in processes:
        p.join()