from subprocess import Popen, PIPE
import re
import os
import random

server_file_name = 'temp_submit_server.sh'
first_worker_file_name = 'temp_submit_worker_0.sh'
second_worker_file_name = 'temp_submit_worker_1.sh'

# Delete output from previous run
os.system('rm -rf errors/*')
os.system('rm -rf output/*')

# Delete exsiting submit submit scripts
os.system('rm ' + first_worker_file_name)
os.system('rm ' + second_worker_file_name)
os.system('rm ' + server_file_name)

# Get the name of the user
proc = Popen(['whoami'], stdout=PIPE, stderr=PIPE)
o, _ = proc.communicate()
username = o.decode('ascii').strip()

# Get the gpu partition info
cmd = ['sinfo', '-p', 'gpu']
proc = Popen(cmd, stdout=PIPE, stderr=PIPE)
o, _ = proc.communicate()
output = o.decode('ascii')
print(output)

# Find the idle gpu machines
output = output[output.find('idle'):].strip()  # idle gl[number, number-number]
output = output[output.find('['):]  # [number, number-number]
output = output[1:-1]  # number, number-number

candidates = []
# Check if there are enough idle gpu machines
if len(output) == 0:
    print("There are not enough idle gpu machines!")
    exit(1)

entries = output.split(',')
for each in entries:
    if '-' in each:
        begin, end = each.split('-')
        print(begin, end)
        for num in range(int(begin), int(end)):
            if (num!=1017):
                candidates.append("gl" + str(num))
    else:
        if (each!="1017"):
            candidates.append("gl" + each)
first_idle_node, second_idle_node, third_idle_node = sorted(random.sample(candidates, 3))

print("Found three idle gpu machine nodes: {}, {}, {}\n".format(
    first_idle_node, second_idle_node, third_idle_node))

# Create new temporary submit scripts
# Server
with open("submit_server.sh", 'r') as base_file:
    new_file_data = base_file.read().replace('$(username)', username).replace('$(target_node)', first_idle_node)
    with open(server_file_name, 'w') as new_file:
        new_file.write(new_file_data)

# Workers
with open("submit_worker.sh", 'r') as base_file:
    base_worker_file_data = base_file.read()

    first_submit_worker_script = base_worker_file_data.replace('$(worker_number)', '0').replace(
        '$(target_node)', second_idle_node).replace('$(username)', username).replace('$(rank)', '1').replace('$(master_addr)', first_idle_node)

    second_submit_worker_script = base_worker_file_data.replace('$(worker_number)', '1').replace(
        '$(target_node)', third_idle_node).replace('$(username)', username).replace('$(rank)', '2').replace('$(master_addr)', first_idle_node)

    with open(first_worker_file_name, 'w') as first_submit_file:
        first_submit_file.write(first_submit_worker_script)

    with open(second_worker_file_name, 'w') as second_submit_file:
        second_submit_file.write(second_submit_worker_script)

# Use sbatch to submit all jobs

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

