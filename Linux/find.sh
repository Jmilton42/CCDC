#!/bin/bash

if find /path -name '.*shrc' -delete; then #This is looking for any files that has .shrc type and delete them
    echo "Found .*shrc files!" #If their was any it will prints this output
else
    echo "Found nothing" #If there wasn't any it prints this output
fi
if find /path -name '.*profile' -delete; then #This is looking for any files that has .profile type and delete them
    echo "Found .*profile files!" #If their was any it will prints this output
else
    echo "Found nothing" #If there wasn't any it prints this output
fi