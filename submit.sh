#!/bin/bash
# The interpreter used to execute the script

#“#SBATCH” directives that convey submission options:

#SBATCH --job-name=test
#SBATCH --mail-user=zwq@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=1000m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log

# The application(s) to execute along with its input arguments and options:
# module load cuda/10.0.130
module load singularity
nvidia-smi
singularity exec test3.simg /home/zwq/EECS598_Proj/byteps.sh

/bin/hostname
sleep 60