
nvidia-smi

# now you are in docker environment
export NVIDIA_VISIBLE_DEVICES=0  # gpus list
export DMLC_WORKER_ID=0 # your worker id
export DMLC_NUM_WORKER=1 # one worker
export DMLC_ROLE=worker

# the following value does not matter for non-distributed jobs
export DMLC_NUM_SERVER=1
export DMLC_PS_ROOT_URI=15.0.0.3
export DMLC_PS_ROOT_PORT=7214

pip3 install psrecord
export PATH=$PATH:~/.local/bin

psrecord "bpslaunch python3 /usr/local/byteps/example/pytorch/benchmark_byteps.py --model resnet50 --num-iters 100" --log activity.txt --plot plot.png

#psrecord "bpslaunch python3 /usr/local/byteps/example/pytorch/benchmark_byteps.py --model resnet50 --num-iters 100" --log activity.txt --plot plot.png
