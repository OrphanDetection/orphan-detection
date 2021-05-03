#!/bin/bash

# Domain name
domain=$1
# File that contains orphan pages
pages=$2
# Parameters
parameters=${3:-"../Data/Input/dld_parameters/default"}
# Directory to store results
data="../Data/Results/"
# Copy of the pages to iterate over
whitelist="${data}${domain}/whitelist"


# Copy links to file
cat $pages | awk '{print $1}' > $whitelist

# Execute URL detection
python3 dude_heuristic.py $domain $whitelist $parameters

# Copy remaning links to new file
mv $whitelist ${pages}_after_link_detection
# Make sure the pages are not world-readable
chmod 0600 ${pages}_after_link_detection

