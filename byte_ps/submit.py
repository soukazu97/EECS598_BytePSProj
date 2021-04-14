from subprocess import Popen, PIPE
import re
import os
import random

scheduler_file_name = 'distributed_submits/temp_submit_scheduler.sh'
server_file_name = 'distributed_submits/temp_submit_server.sh'
first_worker_file_name = 'distributed_submits/temp_submit_worker_0.sh'
second_worker_file_name = 'distributed_submits/temp_submit_worker_1.sh'

# Delete exsiting submit submit scripts
os.system('rm ' + first_worker_file_name)
os.system('rm ' + second_worker_file_name)
os.system('rm ' + scheduler_file_name)
os.system('rm ' + server_file_name)
os.system('rm ./errors/*')
os.system('rm ./output/*')
os.system('rm ./logs/*')

# Get the name of the user
proc = Popen(['whoami'], stdout=PIPE, stderr=PIPE)
o, _ = proc.communicate()
username = o.decode('ascii').strip()

# Get the gpu partition info
cmd = ['sinfo', '-p', 'gpu']
proc = Popen(cmd, stdout=PIPE, stderr=PIPE)
o, _ = proc.communicate()
original_output = o.decode('ascii')
print(original_output)

# Find the idle gpu machines
# idle gl[number, number-number]
idle = original_output[original_output.find('idle'):].strip()
idle = idle[idle.find('['):]  # [number, number-number]
# idle = idle[1:-1]  # number, number-number
idle = idle[idle.find('[')+1:idle.find(']')]

mix = original_output[original_output.find('mix'):].strip()
mix = mix[mix.find('['):].strip()  # [number, number-number]
# mix = mix[1:-1]  # number, number-number
mix = mix[mix.find('[')+1:mix.find(']')]

nodes = idle

candidates = []
# Check if there are enough idle gpu machines
if len(idle) < 5:
    print("There are not enough idle gpu machines! Switching to using mix nodes now!")
    nodes = mix

entries = nodes.split(',')
for each in entries:
    if '-' in each:
        begin, end = each.split('-')
        print(begin, end)
        for num in range(int(begin), int(end)):
            candidates.append("gl" + str(num))
    else:
        candidates.append("gl" + each)
first_idle_node, second_idle_node = sorted(random.sample(candidates, 2))

print("Found two gpu machine nodes: {} and {}\n".format(
    first_idle_node, second_idle_node))

# Create new temporary submit scripts
# Schduler
with open("distributed_submits/submit_scheduler_base.sh", 'r') as base_file:
    new_file_data = base_file.read().replace('$(username)', username)
    with open(scheduler_file_name, 'w') as new_file:
        new_file.write(new_file_data)

# Server
with open("distributed_submits/submit_server_base.sh", 'r') as base_file:
    new_file_data = base_file.read().replace('$(username)', username)
    with open(server_file_name, 'w') as new_file:
        new_file.write(new_file_data)

# Workers
with open("distributed_submits/submit_worker_base.sh", 'r') as base_file:
    base_worker_file_data = base_file.read()

    first_submit_worker_script = base_worker_file_data.replace('$(worker_number)', '0').replace(
        '$(target_node)', first_idle_node).replace('$(username)', username)

    second_submit_worker_script = base_worker_file_data.replace('$(worker_number)', '1').replace(
        '$(target_node)', second_idle_node).replace('$(username)', username)

    with open(first_worker_file_name, 'w') as first_submit_file:
        first_submit_file.write(first_submit_worker_script)

    with open(second_worker_file_name, 'w') as second_submit_file:
        second_submit_file.write(second_submit_worker_script)

# Use sbatch to submit all jobs

# Scheduler
submit_scheduler_cmd = ['sbatch', scheduler_file_name]
proc = Popen(submit_scheduler_cmd, stdout=PIPE,
             stderr=PIPE)
o, e = proc.communicate()
if o:
    print("Submitted scheduler job: ", o.decode('ascii'))
if e:
    print("Error submitting scheduler job: ", e.decode('ascii'))

# Server
submit_server_cmd = ['sbatch', server_file_name]
proc = Popen(submit_server_cmd, stdout=PIPE,
             stderr=PIPE)
o, e = proc.communicate()
if o:
    print("Submitted server job: ", o.decode('ascii'))
if e:
    print("Error submitting server job: ", e.decode('ascii'))

# Workers
submit_first_worker_cmd = ['sbatch', first_worker_file_name]
proc = Popen(submit_first_worker_cmd, stdout=PIPE,
             stderr=PIPE)
o, e = proc.communicate()
if o:
    print("Submitted first worker job: ", o.decode('ascii'))
if e:
    print("Error submitting first worker job: ", e.decode('ascii'))

submit_second_worker_cmd = ['sbatch', second_worker_file_name]
proc = Popen(submit_second_worker_cmd, stdout=PIPE,
             stderr=PIPE)
o, e = proc.communicate()
if o:
    print("Submitted second worker job: ", o.decode('ascii'))
if e:
    print("Error submitting second worker job", e.decode('ascii'))
