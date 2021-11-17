#!/usr/bin/python3

import os.path
import subprocess
import argparse

PI_VERSION_FILE = '/etc/rpi-issue'
SUPPORTED_PI_VERSIONS = ['2019-09-26']

def check_raspberry_version():
    if os.uname().sysname != 'Linux':
        raise ValueError('Not Linux')
    try:
        data = open(PI_VERSION_FILE, "r").read()
    except:
        raise ValueError(f'Could not read {PI_VERSION_FILE} -- is this a raspberry pi?')
    if not any([f in data for f in SUPPORTED_PI_VERSIONS]):
        raise ValueError('Raspberry Pi version not supported by DEBI.')

def enable_camera():
    """Enable camera in /boot/config.txt using raspi-config.

    Confusingly raspi-config get_camera returns "0" when enabled
    and 1 if disabled, but do_camera uses the opposite.
    """

    subprocess.run('raspi-config nonint do_camera 0'.split(), check=True)

# drdebi -- by default check various things

def fix_vnc():
    cmd = 'systemctl restart vncserver-x11-serviced.service'.split()
    subprocess.run(args=cmd, check=True)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--fixvnc', action='store_true', help='reset vnc server')
    args = parser.parse_args()
    if args.fixvnc:
        fix_vnc()
    check_raspberry_version()
    enable_camera()
