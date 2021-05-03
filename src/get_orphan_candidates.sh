#!/bin/bash
zipFile="$1"
archiveFile="${zipFile%.gz}"
filename="${archiveFile##*/}"
name="${filename%_*}"
tmp="../Data/tmp/"
data="../Data/"
domainTmpFolder="${tmp}${name}/"
domainFolder="${data}Results/${name}/"

# Unzip archive file
gunzip $zipFile

# Get entries from 2020 | print the url | filter on unique entries
# Output will be considered as the current sitemap
cat $archiveFile | awk '$1 ~ /^2020/' | awk '{print $2}' | awk '!seen[$1]++' > ${domainTmpFolder}${name}_unique_links_2020
# Make sure data is not world readable
chmod 0600 ${domainTmpFolder}${name}_unique_links_2020

# Print all url's | filter on unique entries
cat $archiveFile | awk '{print $2}' | awk '!seen[$1]++' > ${domainTmpFolder}${name}_unique_links_total
# Make sure data is not world readable
chmod 0600 ${domainTmpFolder}${name}_unique_links_total

# Zip back archive file
gzip $archiveFile
chmod 0600 $zipFile

# Check which links from the past are not in the current sitemap
diff --new-line-format="" --unchanged-line-format="" <(sort ${domainTmpFolder}${name}_unique_links_total) <(sort ${domainTmpFolder}${name}_unique_links_2020) > ${domainFolder}${name}_orphan_candidates
# Make sure data is not world readable
chmod 0600 ${domainFolder}${name}_orphan_candidates
