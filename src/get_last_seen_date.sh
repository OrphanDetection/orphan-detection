#!/bin/bash
urls=$1
export domain=$2
date=$3
archiveFolder="../Data/Archive_Data/"
archiveData="${archiveFolder}${domain}_${date}.txt.gz"

# Function to find the last seen date (provided the file is reversed)
get_date () {
    line=$1
    url=$(echo $line | awk '{print $1}')
    size=$(echo $line | awk '{print $2}')
    # Look for the date the url was last seen
    last=$(cat ${domain}_reverse.txt | grep -F -m 1 " ${url} " | awk '{print $1}')
    
    # Write our result
    echo "${url} ${size} ${last}"

}
export -f get_date



# Unzip archive file and reverse order (so last seen date appears first)
gunzip ${archiveData}
tac ${archiveFolder}${domain}_${date}.txt > ${domain}_reverse.txt

# Find the dates
cat $urls | parallel -j1 get_date > "../Data/tmp/${domain}/"${domain}_with_dates

# Zip archive file and remove reversed file
gzip ${archiveFolder}${domain}_${date}.txt
rm ${domain}_reverse.txt
