#!/bin/bash

sed -i -E 's/NOPASSWD:/PASSWD:/g' /etc/sudoers
sed -i -E 's/NOPASSWD:/PASSWD:/g' /etc/sudoers.d/*
