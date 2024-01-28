#!/bin/bash

find /root /home -name '.*rc' -exec mv {} {}.bak \;
find /root /home -name '.*profile' -exec mv {} {}.bak \;