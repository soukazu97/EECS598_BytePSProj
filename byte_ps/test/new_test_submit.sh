#!/bin/bash
# The interpreter used to execute the script


# Shared properties
#SBATCH --error=/home/%u/EECS598_BytePSProj/byte_ps/test/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/byte_ps/test/output/%x-%j.log
#SBATCH --job-name=test_byteps
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --account=eecs598s009w21_class
#SBATCH --time=5:00:00

# Scheduler properties
#SBATCH --cpus-per-task=1 --nodes=1 --ntasks-per-node=1 --mem-per-cpu=4g --partition=standard --nodelist=gl3131 --ntasks=1

#SBATCH hetjob

# Server properties
#SBATCH --cpus-per-task=1 --nodes=1 --ntasks-per-node=1 --mem-per-cpu=4g --partition=standard --ntasks=1

# Run scheduler
srun --het-group=0 singularity exec --nv /home/jianbinz/EECS598_BytePSProj/byte_ps/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/byte_ps/distributed_scripts/scheduler.sh
sleep 60

# Run server
srun --het-group=1 top -b -d 0.5 | grep jianbinz | grep python3 > /home/jianbinz/EECS598_BytePSProj/byte_ps/test/logs/byteps_server_0.txt &
srun --het-group=1 singularity exec --nv /home/jianbinz/EECS598_BytePSProj/byte_ps/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/byte_ps/distributed_scripts/server.sh
sleep 60

# # Run worker
# srun --het-group=2 module load singularity
# srun --het-group=2 top -b -d 0.1 | grep jianbinz | grep python3 > /home/jianbinz/EECS598_BytePSProj/byte_ps/test/logs/byteps_worker_0.txt &
# srun --het-group=2 singularity exec --nv /home/jianbinz/EECS598_BytePSProj/byte_ps/bytepsimage.simg /home/jianbinz/EECS598_BytePSProj/byte_ps/distributed_scripts/worker_0.sh
# sleep 60
