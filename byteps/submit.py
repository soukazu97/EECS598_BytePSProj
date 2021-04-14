from subprocess import Popen, PIPE
import re
import os
import random
import argparse
import socket

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description="BytePS")

    parser.add_argument(
        "--num_servers",
        type=int,
        default=1,
        help="""The number of servers.""")

    args = parser.parse_args()

    scheduler_submit = 'distributed_submits/temp_submit_scheduler.sh'
    server_submit_0 = 'distributed_submits/temp_submit_server_0.sh'
    server_submit_1 = 'distributed_submits/temp_submit_server_1.sh'
    worker_submit_0 = 'distributed_submits/temp_submit_worker_0.sh'
    worker_submit_1 = 'distributed_submits/temp_submit_worker_1.sh'

    scheduler_run = 'distributed_scripts/temp_run_scheduler.sh'
    server_run_0 = 'distributed_scripts/temp_run_server_0.sh'
    server_run_1 = 'distributed_scripts/temp_run_server_1.sh'
    worker_run_0 = 'distributed_scripts/temp_run_worker_0.sh'
    worker_run_1 = 'distributed_scripts/temp_run_worker_1.sh'

    # Delete output from previous run
    os.system('rm -rf errors/*')
    os.system('rm -rf output/*')
    os.system('rm -rf logs/*')

    # Delete exsiting submit scripts
    os.system('rm ' + worker_submit_0)
    os.system('rm ' + worker_submit_1)
    os.system('rm ' + scheduler_submit)
    os.system('rm ' + server_submit_0)
    os.system('rm ' + server_submit_1)

    # Delete exsiting run scripts
    os.system('rm ' + worker_run_0)
    os.system('rm ' + worker_run_1)
    os.system('rm ' + scheduler_run)
    os.system('rm ' + server_run_0)
    os.system('rm ' + server_run_1)

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

    # Check if there are enough idle gpu machines
    if len(idle) < 5:
        print("There are not enough idle gpu machines! Switching to using mix nodes now!")
        nodes = mix

    candidates = []
    entries = nodes.split(',')
    for each in entries:
        if '-' in each:
            begin, end = each.split('-')
            for num in range(int(begin), int(end)):
                candidates.append("gl" + str(num))
        else:
            candidates.append("gl" + each)

    first_idle, second_idle, third_idle, forth_idle, fifth_idle = sorted(
        random.sample(candidates, 5))

    print("Found 5 idle gpu machine nodes: {}, {}, {}, {}, and {}\n".format(
        first_idle, second_idle, third_idle, forth_idle, fifth_idle))

    # Get the ip of the first_idle, which is the scheduler node
    scheduler_ip = socket.gethostbyname(first_idle)

    # Create new temporary run scripts
    # Schduler
    with open("distributed_scripts/run_scheduler_base.sh", 'r') as base_file:
        new_file_data = base_file.read().replace(
            '$(num_servers)', str(args.num_servers)).replace('$(scheduler_ip)', scheduler_ip)
        with open(scheduler_run, 'w') as new_file:
            new_file.write(new_file_data)

    # Server
    with open("distributed_scripts/run_server_base.sh", 'r') as base_file:
        base_server_file_data = base_file.read().replace(
            '$(num_servers)', str(args.num_servers)).replace('$(scheduler_ip)', scheduler_ip)

        with open(server_run_0, 'w') as new_file:
            new_file.write(base_server_file_data)

        with open(server_run_1, 'w') as new_file:
            new_file.write(base_server_file_data)

    # Workers
    with open("distributed_scripts/run_worker_base.sh", 'r') as base_file:
        base_worker_file_data = base_file.read().replace(
            '$(num_servers)', str(args.num_servers)).replace('$(scheduler_ip)', scheduler_ip)

        first_submit_worker_script = base_worker_file_data.replace(
            '$(worker_num)', '0')

        second_submit_worker_script = base_worker_file_data.replace(
            '$(worker_num)', '1')

        with open(worker_run_0, 'w') as first_submit_file:
            first_submit_file.write(first_submit_worker_script)

        with open(worker_run_1, 'w') as second_submit_file:
            second_submit_file.write(second_submit_worker_script)

    # Create new temporary submit scripts
    # Schduler
    with open("distributed_submits/submit_scheduler_base.sh", 'r') as base_file:
        new_file_data = base_file.read().replace(
            '$(username)', username).replace('$(target_node)', first_idle)
        with open(scheduler_submit, 'w') as new_file:
            new_file.write(new_file_data)

    # Server
    with open("distributed_submits/submit_server_base.sh", 'r') as base_file:
        base_server_file_data = base_file.read().replace(
            '$(username)', username)

        first_submit_server_script = base_server_file_data.replace(
            '$(server_number)', '0').replace('$(target_node)', second_idle)

        second_submit_server_script = base_server_file_data.replace(
            '$(server_number)', '1').replace('$(target_node)', third_idle)

        with open(server_submit_0, 'w') as new_file:
            new_file.write(first_submit_server_script)

        with open(server_submit_1, 'w') as new_file:
            new_file.write(second_submit_server_script)

    # Workers
    with open("distributed_submits/submit_worker_base.sh", 'r') as base_file:
        base_worker_file_data = base_file.read().replace('$(username)', username)

        first_submit_worker_script = base_worker_file_data.replace('$(worker_number)', '0').replace(
            '$(target_node)', forth_idle)

        second_submit_worker_script = base_worker_file_data.replace('$(worker_number)', '1').replace(
            '$(target_node)', fifth_idle)

        with open(worker_submit_0, 'w') as first_submit_file:
            first_submit_file.write(first_submit_worker_script)

        with open(worker_submit_1, 'w') as second_submit_file:
            second_submit_file.write(second_submit_worker_script)

    # Use sbatch to submit all jobs
    # exit()

    # Scheduler
    submit_scheduler_cmd = ['sbatch', scheduler_submit]
    proc = Popen(submit_scheduler_cmd, stdout=PIPE,
                 stderr=PIPE)
    o, e = proc.communicate()
    if o:
        print("Submitted scheduler job: ", o.decode('ascii'))
    if e:
        print("Error submitting scheduler job: ", e.decode('ascii'))

    # Server
    submit_server_cmd = ['sbatch', server_submit_0]
    proc = Popen(submit_server_cmd, stdout=PIPE,
                 stderr=PIPE)
    o, e = proc.communicate()
    if o:
        print("Submitted first server job: ", o.decode('ascii'))
    if e:
        print("Error submitting first server job: ", e.decode('ascii'))

    if args.num_servers == 2:
        submit_server_cmd = ['sbatch', server_submit_1]
        proc = Popen(submit_server_cmd, stdout=PIPE,
                     stderr=PIPE)
        o, e = proc.communicate()
        if o:
            print("Submitted second server job: ", o.decode('ascii'))
        if e:
            print("Error submitting second server job: ", e.decode('ascii'))

    # Workers
    submit_first_worker_cmd = ['sbatch', worker_submit_0]
    proc = Popen(submit_first_worker_cmd, stdout=PIPE,
                 stderr=PIPE)
    o, e = proc.communicate()
    if o:
        print("Submitted first worker job: ", o.decode('ascii'))
    if e:
        print("Error submitting first worker job: ", e.decode('ascii'))

    submit_second_worker_cmd = ['sbatch', worker_submit_1]
    proc = Popen(submit_second_worker_cmd, stdout=PIPE,
                 stderr=PIPE)
    o, e = proc.communicate()
    if o:
        print("Submitted second worker job: ", o.decode('ascii'))
    if e:
        print("Error submitting second worker job", e.decode('ascii'))
