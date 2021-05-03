#!/bin/bash
domain="$1"
date=${2:-$(date +'%Y-%m-%d')}
data="../Data/"
sitemapsLocal="${data}Archive_Data/"
archiveFile="${sitemapsLocal}/${domain}_${date}.txt"

mkdir -p ${sitemapsLocal}

# Retrieve archive data
echo "Retrieving archive data for ${domain}."
# Time retrieval
start=`date +%s`
curl -s 'https://web.archive.org/cdx/search/cdx?url='${domain}'&matchType=domain&fl=timestamp,original,length&filter=statuscode:200' > $archiveFile
# Make sure data is not world readable
chmod 0600 $archiveFile

# End timing
end=`date +%s`
echo "Retrieving archive data for ${domain} took `expr $end - $start` seconds."


start=`date +%s`
echo "Zipping ${domain} archive file."
gzip $archiveFile
chmod 0600 ${archiveFile}.gz
end=`date +%s`
echo "Zipping ${domain} archive file took `expr $end - $start` seconds."

