#!/bin/bash
ansible-playbook -T 30 -b --ask-become-pass --ask-pass  ~/Apt-Proxy-Setup/update-services.sh

