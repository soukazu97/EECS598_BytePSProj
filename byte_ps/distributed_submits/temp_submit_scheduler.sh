#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=bps_scheduler
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32768m
#SBATCH --partition=standard
#SBATCH --nodelist=gl3131

#SBATCH --account=eecs598s009w21_class
#SBATCH --error=/home/%u/EECS598_BytePSProj/byte_ps/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/byte_ps/output/%x-%j.log
#SBATCH --time=5:00:00

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

# Run the scheduler node
singularity exec --nv /home/jianbinz/EECS598_BytePSProj/byte_ps/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/byte_ps/distributed_scripts/scheduler.sh

/bin/hostname
sleep 60
