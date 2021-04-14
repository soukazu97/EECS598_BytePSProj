#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=byteps_server_$(server_number)
#SBATCH --mail-user=$(username)@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32768m
#SBATCH --error=/home/%u/EECS598_BytePSProj/byteps/errors/error_%x-%j.log
#SBATCH --gpus-per-node=1
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/EECS598_BytePSProj/byteps/output/%x-%j.log
#SBATCH --nodelist=$(target_node)
#SBATCH --account=eecs598s009w21_class

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

timeout 30m top -b -d 0.1 | grep $(username) | grep python3 > /home/$(username)/EECS598_BytePSProj/byteps/logs/byteps_server_$(server_number).txt &

# Run the server node
singularity exec --nv /home/$(username)/EECS598_BytePSProj/byteps/bytepsimage.simg /home/$(username)/EECS598_BytePSProj/byteps/distributed_scripts/temp_run_server_$(server_number).sh

/bin/hostname
sleep 60
