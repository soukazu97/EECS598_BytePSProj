#!/bin/bash
# The interpreter used to execute the script

#SBATCH --account=eecs598s009w21_class
#SBATCH --job-name=ps
#SBATCH --mail-user=zwq@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/EECS598_BytePSProj/parameter_server/errors/error_%x-%j.log
#SBATCH --cpus-per-task=4
#SBATCH --nodes=1
#SBATCH --time=5:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=8G
#SBATCH --partition=standard
#SBATCH --output=/home/%u/EECS598_BytePSProj/parameter_server/output/%x-%j.log
#SBATCH --nodelist=gl3237

# The application(s) to execute along with its input arguments and options:

# If only want run 10 minutes, add "timeout 10m"
# Monitor cpu usage, put into a log file
top -b -d 0.5 | grep zwq | grep python3 > /home/zwq/EECS598_BytePSProj/parameter_server/logs/ps_RES50_server.txt &

# Run the server node
srun singularity exec --nv /home/zwq/EECS598_BytePSProj/psimage.simg \
python3 /home/zwq/EECS598_BytePSProj/parameter_server/ps_RESNET50.py --world_size=3 --rank=0 \
--num_gpus=1 --master_addr=gl3237 --master_port=7214 --batch_size=32

