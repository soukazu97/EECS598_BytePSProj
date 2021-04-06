#!/bin/bash
# The interpreter used to execute the script

#SBATCH --account=eecs598s009w21_class
#SBATCH --job-name=ps
#SBATCH --mail-user=$(username)@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/EECS598_BytePSProj/parameter_server/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/parameter_server/output/%x-%j.log

# The application(s) to execute along with its input arguments and options:

# worker() {
#        sleep(5)
#        nodeID = check status | grep "SchedNodeList"

#        # Run the worker0 node 
#        srun --het_group=1 singularity exec --nv /home/$(username)/EECS598_BytePSProj/psimage.simg \
#        python3 /home/$(username)/EECS598_BytePSProj/parameter_server/ps_RESNET50.py --world_size=3 --rank=1 \
#        --num_gpus=1 --master_addr=${nodeID} --master_port=7214 &
#        # Run the worker1 node 
#        srun --het_group=2 singularity exec --nv /home/$(username)/EECS598_BytePSProj/psimage.simg \
#        python3 /home/$(username)/EECS598_BytePSProj/parameter_server/ps_RESNET50.py --world_size=3 --rank=2 \
#        --num_gpus=1 --master_addr=${nodeID} --master_port=7214 &
# }

srun hostname -s

module load singularity


salloc -N1 -n1 --mem-per-cpu=1G :\
       -N1 -n1 -G1 --mem-per-cpu=1G :\
       -N1 -n1 -G1 --mem-per-cpu=1G

srun --het-group=0 env | grep SLURM &
echo '=========================================='
srun --het-group=1 env | grep SLURM &
echo '=========================================='
srun --het-group=2 env | grep SLURM &

# srun --het-group=0 singularity exec --nv /home/$(username)/EECS598_BytePSProj/psimage.simg \
# python3 /home/$(username)/EECS598_BytePSProj/parameter_server/ps_RESNET50.py --world_size=3 --rank=0 \
# --num_gpus=1 --master_addr=localhost --master_port=7214 &

# worker &
wait