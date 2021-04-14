
nvidia-smi

# now you are in docker environment
export NVIDIA_VISIBLE_DEVICES=0  # gpus list
export DMLC_WORKER_ID=$(worker_num) # your worker id
export DMLC_NUM_WORKER=2 # two workers
export DMLC_ROLE=worker

# the following value does not matter for non-distributed jobs
export DMLC_NUM_SERVER=$(num_servers)
export DMLC_PS_ROOT_URI=$(scheduler_ip) # the scheduler IP
export DMLC_PS_ROOT_PORT=7214

bpslaunch python3 /usr/local/byteps/example/pytorch/benchmark_byteps.py --model resnet50 --num-iters 100
