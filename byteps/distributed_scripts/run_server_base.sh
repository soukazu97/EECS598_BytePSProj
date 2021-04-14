# now you are in docker environment
export DMLC_NUM_WORKER=2
export DMLC_ROLE=server
export DMLC_NUM_SERVER=$(num_servers)
export DMLC_PS_ROOT_URI=$(scheduler_ip) # the scheduler IP
export DMLC_PS_ROOT_PORT=7214  # the scheduler port

bpslaunch
