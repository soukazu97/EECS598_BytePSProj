#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=test_byteps
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log

# The application(s) to execute along with its input arguments and options:
# module load cuda/10.0.130

srun hostname -s

module load singularity

singularity exec --nv /home/jianbinz/EECS598_BytePSProj/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/single_machine/test.sh

/bin/hostname
sleep 60
