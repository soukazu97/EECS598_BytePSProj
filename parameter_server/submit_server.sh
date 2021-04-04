#!/bin/bash
# The interpreter used to execute the script

#SBATCH --account=eecs598s009w21_class
#SBATCH --job-name=ps
#SBATCH --mail-user=$(username)@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/EECS598_BytePSProj/parameter_server/errors/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/EECS598_BytePSProj/parameter_server/output/%x-%j.log
#SBATCH --nodelist=$(target_node)

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

# Run the server node
singularity exec --nv /home/$(username)/EECS598_BytePSProj/psimage.simg \
python3 /home/$(username)/EECS598_BytePSProj/parameter_server/rpc_parameter_server.py --world_size=3 --rank=0 \
--num_gpus=1 --master_addr=$(target_node) --master_port=7214 

