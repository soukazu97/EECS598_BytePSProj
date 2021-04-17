#!/bin/bash
# The interpreter used to execute the script

#SBATCH --job-name=horovod
#SBATCH --mail-user=ivanpu@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --account=eecs598s009w21_class
#SBATCH --error=/home/%u/error_%x-%j.log
#SBATCH --cpus-per-task=4
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=1
#SBATCH --gpus-per-node=1
#SBATCH --mem-per-cpu=32768m 
#SBATCH --partition=gpu
#SBATCH --output=/home/%u/%x-%j.log


# The application(s) to execute along with its input arguments and options:

export http_proxy="http://proxy.arc-ts.umich.edu:3128/"
export https_proxy="http://proxy.arc-ts.umich.edu:3128/"
export ftp_proxy="http://proxy.arc-ts.umich.edu:3128/"
export no_proxy="localhost,127.0.0.1,.localdomain,.umich.edu"
export HTTP_PROXY="${http_proxy}"
export HTTPS_PROXY="${https_proxy}"
export FTP_PROXY="${ftp_proxy}"
export NO_PROXY="${no_proxy}"

srun hostname

module purge

module load tensorflow/2.4.1 gcc/8.2.0 openmpi/4.0.3
module load cmake

timeout 10m top -b -d 0.5 | grep $(whoami) | grep python > log-$(hostname).txt &

mpirun -np 2 -npernode 1 --verbose python /home/ivanpu/EECS598_Proj/horovod/pytorch_resnet152.py --epochs=1


# module load tensorflow/2.4.1 gcc/8.2.0 openmpi/4.0.3

# pip install --user horovod


# timeout 10m top -b -d 0.5 | grep $(whoami) | grep python > log-$(hostname).txt &

# mpirun -np 2 -npernode 1 python /home/ivanpu/EECS598_Proj/horovod/synthetic.py --model ResNet50 --num-iters 100

sleep 60
