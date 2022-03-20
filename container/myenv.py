#! /usr/bin/python3

import subprocess
import argparse
import os
import sys

# TODO : Externalize file list and directories/paths to config file to remove Micronisms

help_command = """
     in container commands : c_push c_pull
outside container commands : h_push h_pull

push : Copying config files form the host or inside the container to a tgz in a shared folder.
pull : Overwritting existing config files with files from the tgz in the shared folder.

On the host side, actual environment config files are not used, only the files in the myenv repo.
On the container side, the actual environment config files are pushed/pulled.
"""

parser = argparse.ArgumentParser(description='Tool for pushing/pulling config files out of and into a container.', formatter_class=argparse.RawTextHelpFormatter)
parser.add_argument('command', choices=['c_push', 'c_pull', 'h_push', 'h_pull'], help=help_command)
parser.add_argument('-f', action='store_true', help='Force the operation')
args = parser.parse_args()

files = [
  '.config/nvim/init.lua',
  '.config/nvim/coc-settings.json',
  '.bashrc',
  '.tmux.conf',
  'myenv.py'
]
file_list = ' '.join(files)
print(file_list)

file_arch_name = 'myenv.tgz'

def CreateTar(dest_path_or_dir, basepath='~'):
  
    subprocess.check_call('cd {:s} ; tar czf /tmp/{:s} {:s}'.format(basepath, file_arch_name, file_list), shell=True)
    subprocess.check_call('mv /tmp/{:s} {:s}'.format(file_arch_name, dest_path_or_dir), shell=True)

def ContainerCommand(cmd):
    """Handle commands that are executed inside the container."""
    dest_dir = '/mnt/fw'
    file_arch_path = '{:s}/{:s}'.format(dest_dir, file_arch_name)
    file_backup_name = '.myenv.tgz'
    file_backup_path = '~/{:s}'.format(file_backup_name)
    file_last_push = '.myenv_last_push_ts'

    if cmd == 'c_push':
        CreateTar(dest_dir)

        # Save last push date
        subprocess.check_call('touch {:s}'.format(file_last_push), shell=True)

        print('Changes pushed to {:s} successfully.'.format(file_arch_path))

    elif cmd == 'c_pull':

        # Check if any config files are newer than the archive
        if os.path.isfile(file_last_push) and not args.f:
            time_arch = os.path.getmtime(file_last_push)
            time_files = [os.path.getmtime(f) for f in files]

            for ind,tm in enumerate(time_files):
                if time_arch < tm:
                    print('Local files are nwer than files being pulled, consider pushing first (or you can use -f but local files will be overwritten).')
                    print(files[ind])
                    sys.exit(1)

        # Backup existing files before pulling in new ones
        CreateTar(file_backup_path)

        # Pull in tgz, unzip, and overwrite files
        if not os.path.isfile(file_arch_path):
            print('{:s} not found, nothing to pull.'.format(file_arch_path))
            sys.exit(1)

        subprocess.check_call('cp {:s} ~'.format(file_arch_path), shell=True)
        subprocess.check_call('cd ~ ; tar xzf {:s}'.format(file_arch_name), shell=True)
        subprocess.check_call('cd ~ ; rm {:s}'.format(file_arch_name), shell=True)

        print('Changes pulled successfully (pre-pull backup {:s}).'.format(file_backup_path))

def HostCommand(cmd):
    """Handle commands that are executed on the host systems."""
    shared_dir = '/users/mmccarron/fw'
    file_arch_path = '{:s}/{:s}'.format(shared_dir, file_arch_name)

    if cmd == 'h_push':
        
        CreateTar(shared_dir, basepath='.')
        
        print('Chagnes pushed to {:s} successfully.'.format(file_arch_path))
    
    elif cmd == 'h_pull':
    
        # Pull in tgz, unzip, and overwrite files
        if not os.path.isfile(file_arch_path):
            print('{:s} not found, nothing to pull.'.format(file_arch_path))
            sys.exit(1)
            
        subprocess.check_call('cp {:s} .'.format(file_arch_path), shell=True)
        subprocess.check_call('tar xzf {:s}'.format(file_arch_name), shell=True)
        subprocess.check_call('rm {:s}'.format(file_arch_name), shell=True)
            
        print('Changes pulled successfully.')

####

if args.command[0] == 'c':
    ContainerCommand(args.command)
elif args.command[0] == 'h':
    HostCommand(args.command)


# Check if any config files are newer than the archive

