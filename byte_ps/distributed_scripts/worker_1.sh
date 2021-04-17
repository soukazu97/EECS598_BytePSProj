
nvidia-smi

# now you are in docker environment
export NVIDIA_VISIBLE_DEVICES=0  # gpus list
export DMLC_WORKER_ID=1 # your worker id
export DMLC_NUM_WORKER=2 # two workers
export DMLC_ROLE=worker
export BYTEPS_ENABLE_ASYNC=1
# the following value does not matter for non-distributed jobs
export DMLC_NUM_SERVER=1
export DMLC_PS_ROOT_URI=10.164.8.181
export DMLC_PS_ROOT_PORT=7373

bpslaunch python3 /home/zwq/EECS598_BytePSProj/byte_ps/byteps_RES150.py --batch-size 32 --epochs 3 
