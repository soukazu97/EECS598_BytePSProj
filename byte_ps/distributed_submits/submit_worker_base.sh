#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=bps_worker_$(worker_number)
#SBATCH --mail-user=$(username)@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=2
#SBATCH --mem-per-cpu=16000m 
#SBATCH --partition=gpu
#SBATCH --nodelist=$(target_node)

#SBATCH --account=eecs598s009w21_class
#SBATCH --error=/home/%u/EECS598_BytePSProj/byte_ps/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/byte_ps/output/%x-%j.log
#SBATCH --time=5:00:00

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

timeout 30m top -b -d 0.1 | grep $(username) | grep python3 > /home/$(username)/EECS598_BytePSProj/byte_ps/logs/byteps_worker_$(worker_number).txt &

singularity exec --nv /home/$(username)/EECS598_BytePSProj/byte_ps/bytepsimage.simg /home/$(username)/EECS598_BytePSProj/byte_ps/distributed_scripts/worker_$(worker_number).sh

/bin/hostname
sleep 60
