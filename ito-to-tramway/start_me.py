"""
Main launch point.
Creates the argument list and launches the appropriate job manager.
"""


import os    # for file operations
import socket  # for netowrk hostname
import numpy as np
import argparse  # for command-line arguments
from prepare_arguments import prepare_arguments
import subprocess  # for launching detached processes on a local PC
import sys		# to set exit codes

# Constants
from constants import *


# Define arguments
arg_parser = argparse.ArgumentParser(
    description='Job manager. You must choose whether to resume simulations or restart and regenerate the arguments file')
arg_parser.add_argument('-v', '--version', action='version',
                        version='%(prog)s ' + str(version))
mode_group = arg_parser.add_mutually_exclusive_group(required=True)
mode_group.add_argument('--restart', action='store_true')
mode_group.add_argument('--resume', action='store_true')


# Identify the system where the code is running
hostname = socket.gethostname()
if hostname.startswith('tars-submit'):
    script_name = 'sbatch_tars.sh'
    jobs_count = jobs_count_tars
elif hostname == 'patmos':
    script_name = 'sbatch_t_bayes.sh'
    jobs_count = jobs_count_t_bayes
elif hostname == 'onsager-dbc':
    script_name = 'job_manager.py'
    jobs_count = jobs_count_onsager
else:
    print('Unidentified hostname "' + hostname +
          '". Unable to choose the right code version to launch. Aborting.')
    exit()


# Analyze if need to restart or resume
input_args = arg_parser.parse_args()
bl_restart = input_args.restart


# If restart is required, regenerate all files
if bl_restart:
    print("Creating arguments list...")

    # Clear the arguments file
    try:
        os.remove(args_file)
    except:
        pass

    # # Clean the logs and output folders
    # for folder in (logs_folder, output_folder):
    # 	if os.path.isdir(folder):
    # 		print("Cleaning up the folder: '" + folder + "'.")
    # 		cmd = "rm -rfv " + folder
    # 		try:
    # 			os.system(cmd)
    # 		except Exception as e:
    # 			print(e)

    # 	# Recreate the folder
    # 	try:
    # 		os.makedirs(folder)
    # 	except Exception as e:
    # 		print(e)

    # Clean slurm files in the root folder
    cmd = "rm -fv ./slurm-*"
    try:
        os.system(cmd)
    except Exception as e:
        print(e)

    # # Clean rwa files in the data folder
    # cmd = "rm -fv " + data_folder + "*.rwa"
    # try:
    # 	os.system(cmd)
    # except Exception as e:
    # 	print(e)

    # Write arguments to file
    prepare_arguments()

    # Create lock file
    with open(args_lock, 'w'):
        pass

    print("Argument list created. Launching sbatch...")

    line_count = id
else:
    print("Resuming simulation with the same arguments file")


# Launch job managers
if script_name == 'job_manager.py':
    cmd_str = 'python3 %s' % (script_name)
    child_list = []
    pids = []
    for j in range(1, jobs_count + 1):
        cur_popen = subprocess.Popen(["python3", script_name], stdin=subprocess.PIPE)
        child_list.append(cur_popen)
        pids.append(cur_popen.pid)
    print("Launched %i local job managers." % (jobs_count))
    print("PIDs: ")
    print(pids)

    timeout = 10    # ms

    # def not_finished():
    for j in range(jobs_count):
        child_list[j].wait()

    # # Wait for user input or for children finishing
    # while not_finished():
    #     read_list, _, _ = select([sys.stdin], [], [], timeout)
    #     if read_list:
    #         str = sys.stdin.readline()
    #         print("You typed % s, str)
    #         continue

    print("All job managers finished successfully")

else:
    # -o /dev/null
    cmd_str = 'sbatch --array=1-%i %s' % (jobs_count, script_name)
    os.system(cmd_str)
