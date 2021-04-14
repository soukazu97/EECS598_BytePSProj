#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=byteps_server
#SBATCH --mail-user=$(username)@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/errors/error_%x-%j.log
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32768m
#SBATCH --partition=standard
#SBATCH --output=/home/%u/%x-%j.log

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

timeout 30m top -b -d 0.1 | grep $(username) | grep python3 > /home/$(username)/EECS598_BytePSProj/byteps/logs/byteps_server_$(server_number).txt &

# Run the server node
singularity exec --nv /home/$(username)/EECS598_BytePSProj/bytepsimage.simg /home/$(username)/EECS598_BytePSProj/byte_ps/distributed_scripts/server.sh

/bin/hostname
sleep 60
