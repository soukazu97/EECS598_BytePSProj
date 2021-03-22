#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=byteps_scheduler
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/errors/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32768m
#SBATCH --partition=standard
#SBATCH --output=/home/%u/%x-%j.log
#SBATCH --nodelist=gl3122

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

# Run the scheduler node
singularity exec --nv /home/jianbinz/EECS598_BytePSProj/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/distributed_scripts/scheduler.sh

/bin/hostname
sleep 60
