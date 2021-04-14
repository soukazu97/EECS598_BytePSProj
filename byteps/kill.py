from subprocess import Popen, PIPE
import re
import os


# Get the name of the user
proc = Popen(['whoami'], stdout=PIPE, stderr=PIPE)
o, _ = proc.communicate()
username = o.decode('ascii').strip()

# Get all jobs under username
output = os.popen("squeue | grep {}".format(username)).read()

# Find all job ids
job_ids = [int(s)
           for s in re.findall(r'\d+', output) if int(s) > 10000000]

for job_id in job_ids:
    os.system("scancel {}".format(job_id))
    print("Killed job: ", job_id)

