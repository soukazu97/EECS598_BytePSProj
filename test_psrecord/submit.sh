#!/bin/bash
# The interpreter used to execute the script

#SBATCH --account=eecs598s009w21_class
#SBATCH --job-name=test
#SBATCH --mail-user=jianbinz@umich.edu
#SBATCH --mail-type=BEGIN,END
#SBATCH --error=/home/%u/EECS598_BytePSProj/test_psrecord/error_%x-%j.log
#SBATCH --partition=debug
#SBATCH --output=/home/%u/EECS598_BytePSProj/test_psrecord/%x-%j.log

# The application(s) to execute along with its input arguments and options:
# module load cuda/10.0.130

srun hostname -s

module load singularity
module load allinea_reports

# singularity exec --nv psrecord.simg python test.py 
perf-report singularity exec --nv psrecord.simg python test.py --output=/report

/bin/hostname
sleep 60
