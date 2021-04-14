#!/bin/bash
# The interpreter used to execute the script


# Shared properties
#SBATCH --error=/home/%u/EECS598_BytePSProj/byte_ps/test/errors/error_%x-%j.log
#SBATCH --output=/home/%u/EECS598_BytePSProj/byte_ps/test/output/%x-%j.log
#SBATCH --job-name=test_byteps
#SBATCH --mail-user=zwq@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --account=eecs598s009w21_class
#SBATCH --time=5:00:00
# Worker 0 properties
#SBATCH --cpus-per-task=4 --nodes=1 --ntasks-per-node=1 --gpus-per-node=1 --mem-per-cpu=4g --partition=gpu --ntasks=1
srun timeout 20m top -b -d 0.5 | grep zwq | grep python3 > /home/zwq/EECS598_BytePSProj/byte_ps/test/logs/byteps_worker_0.txt &
srun singularity exec --nv /home/zwq/EECS598_BytePSProj/byteps_newtorch.simg /home/zwq/EECS598_BytePSProj/byte_ps/distributed_scripts/worker_0.sh