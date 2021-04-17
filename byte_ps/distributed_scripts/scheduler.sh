# now you are in docker environment
export DMLC_NUM_WORKER=2
export DMLC_ROLE=scheduler
export DMLC_NUM_SERVER=1
export DMLC_PS_ROOT_URI=10.164.8.181 # the scheduler IP
export DMLC_PS_ROOT_PORT=7373  # the scheduler port
export PS_VERBOSE=2
export BYTEPS_ENABLE_ASYNC=1
bpslaunch