# now you are in docker environment
export DMLC_NUM_WORKER=2
export DMLC_ROLE=server
export DMLC_NUM_SERVER=1
export DMLC_PS_ROOT_URI=10.164.9.59 # the scheduler IP
export DMLC_PS_ROOT_PORT=7214  # the scheduler port

bpslaunch
