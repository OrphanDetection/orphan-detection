#!/bin/bash
links=$1
domain=$2
export tmp="../Data/tmp/pages/"
mkdir -p $tmp
domainTmpFolder="../Data/tmp/${domain}/"

# Method to retrieve size of page
get_length () {
    line=$1
    # Get URL
    url=$(echo $line | awk '{print $1}')
    
    # Hash URL for filename
    name=$(echo $url | md5sum)
    
    # Download page
    curl -s --connect-timeout 2 --max-time 300 "$url" > "${tmp}${name}"
    
    # Get page size
    size=$(stat --printf="%s" "${tmp}${name}")
    
    # Delete downloaded page
    rm "${tmp}${name}"
    
    # Write out result
    echo "$line $size"
    
}
export -f get_length

cat $links | parallel -j10 get_length > ${domainTmpFolder}${domain}_with_size

