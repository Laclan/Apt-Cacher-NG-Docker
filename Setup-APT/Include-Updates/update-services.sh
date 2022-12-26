#!/bin/bash
ansible-playbook -T 30 -b --ask-become-pass --ask-pass  /home/tetio/ansible-playbooks/Setup-APT/Include-Updates/Include-updates.yml

