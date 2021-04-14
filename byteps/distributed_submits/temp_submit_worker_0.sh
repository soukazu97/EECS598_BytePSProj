#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=byteps_worker_0
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log
#SBATCH --nodelist=gl1015

#SBATCH --error=/home/%u/EECS598_BytePSProj/byteps/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/byteps/output/%x-%j.log
#SBATCH --account=eecs598s009w21_class

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

timeout 30m top -b -d 0.1 | grep jianbinz | grep python3 > /home/jianbinz/EECS598_BytePSProj/byteps/logs/byteps_worker_0.txt &

singularity exec --nv /home/jianbinz/EECS598_BytePSProj/byteps/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/byteps/distributed_scripts/temp_run_worker_0.sh

/bin/hostname
sleep 60
