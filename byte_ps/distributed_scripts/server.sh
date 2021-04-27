# now you are in docker environment
export DMLC_NUM_WORKER=2
export DMLC_ROLE=server
export DMLC_NUM_SERVER=1
export DMLC_PS_ROOT_URI=10.164.9.157 # the scheduler IP
export DMLC_PS_ROOT_PORT=1357  # the scheduler port
export BYTEPS_ENABLE_ASYNC=1
export DMLC_ENABLE_RDMA=1

bpslaunch
