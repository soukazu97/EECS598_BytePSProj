#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=byteps_worker_0
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/errors/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

singularity exec --nv bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/worker_0.sh

/bin/hostname
sleep 60
