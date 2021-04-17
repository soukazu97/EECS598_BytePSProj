#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=horovod
#SBATCH --mail-user=ivanpu@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --account=eecs598s009w21_class
#SBATCH --error=/home/%u/error_%x-%j.log
#SBATCH --cpus-per-task=4
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log

# The application(s) to execute along with its input arguments and options:


module load tensorflow/2.4.1 gcc/8.2.0 openmpi/4.0.3

pip install --user horovod

srun hostname

# srun --nodes=4 --tasks-per-node=1 --cpu-per-task=1 /home/ivanpu/EECS598_Proj/horovod/profile.sh &

srun --overcommit /home/ivanpu/EECS598_Proj/horovod/profile.sh &

echo "Test!"

mpirun -np 4 -npernode 1 python /home/ivanpu/EECS598_Proj/horovod/horovod_synthetic_benchmark.py --model ResNet50 --num-iters 100

sleep 60