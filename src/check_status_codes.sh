#!/bin/bash
potential_orphans="$1"
filename="${potential_orphans##*/}"
name="${filename%%_*}"
tmp="../Data/tmp/"
data="../Data/"
domainTmpFolder="${tmp}${name}/"

# Function to check status code for links
curlfunc() {
    url="$1"

    curl -o /dev/null --max-time 1 --silent --head --write-out "%{http_code} $url\n" "$url"
    
}
export -f curlfunc

# Check status codes in parallel
cat $potential_orphans | parallel -j 100 curlfunc > ${domainTmpFolder}${name}_status_codes

# Make sure data is not world readable
chmod 0600 ${domainTmpFolder}${name}_status_codes
