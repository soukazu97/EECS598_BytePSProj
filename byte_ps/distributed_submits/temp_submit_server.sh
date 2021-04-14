#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=bps_server
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=32768m
#SBATCH --partition=standard

#SBATCH --account=eecs598s009w21_class
#SBATCH --error=/home/%u/EECS598_BytePSProj/byte_ps/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/byte_ps/output/%x-%j.log
#SBATCH --time=5:00:00

# The application(s) to execute along with its input arguments and options:

srun hostname -s

module load singularity

top -b -d 0.5 | grep jianbinz | grep python3 > /home/jianbinz/EECS598_BytePSProj/byte_ps/logs/byteps_server_0.txt &

# Run the server node
singularity exec --nv /home/jianbinz/EECS598_BytePSProj/byte_ps/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/byte_ps/distributed_scripts/server.sh

/bin/hostname
sleep 60
