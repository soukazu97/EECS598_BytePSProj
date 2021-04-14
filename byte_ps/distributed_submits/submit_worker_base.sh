#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=byteps_worker_$(worker_number)
#SBATCH --mail-user=$(username)@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/errors/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log
#SBATCH --nodelist=$(target_node)

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

singularity exec --nv /home/$(username)/EECS598_BytePSProj/bytepsimage.simg /home/$(username)/EECS598_BytePSProj/byte_ps/distributed_scripts/worker_$(worker_number).sh

/bin/hostname
sleep 60
