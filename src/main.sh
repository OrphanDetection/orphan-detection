#!/bin/bash

# Determines whether the archive data should be downloaded or not
downloadArchive=true
# Determines whether to perform Dynamic Link Detection or not
dude=false

# The date of the folder to process.
# This represents the date when the archive data was downloaded, if this was done before.
# If no date is given, the date of today is set.
date=$(date +'%Y-%m-%d')

# Get flags
while getopts :s:d flag
do
    case "${flag}" in
        s) downloadArchive=false && date=$OPTARG;;
        d) dude=true;;
        :) echo "Missing argument for option -$OPTARG"; exit 1;;
       \?) echo "Unknown option -$OPTARG"; exit 1;;
    esac
done

# Shift the arguments such that the argument counter starts from 1 again after the flag
shift $(( OPTIND - 1 ))

# Domain to process
domain="$1"
# Location of the sitemaps
sitemaps="../Data/Archive_Data/"
# General data folder
data="../Data/"
# Folder for temporary files
tmp="../Data/tmp/"
# Folder to store the results for the domain being processed
domainFolder="${data}Results/${domain}/" 
# Folder to store temporary data for the domain being processed
domainTmpFolder="${tmp}${domain}/"

# Make de domain folder
mkdir -p $domainFolder
# Make the temporary domain folder
mkdir -p $domainTmpFolder

# Time the process for a full domain
start_total=`date +%s`

# If archive archive data was not yet downloaded, retrieve the archive data
if $downloadArchive
then
    # Download archive data
    bash download.sh ${domain} ${date}
fi

# Extract potential orphan pages
start=`date +%s`
echo "Extracting candidate orphan pages for ${domain}."
bash get_orphan_candidates.sh ${sitemaps}${domain}_${date}.txt.gz
end=`date +%s`
numberOfPages=$(wc -l ${domainTmpFolder}${domain}_orphan_candidates | awk '{print $1}')
echo "Extracting candidate orphan pages for ${domain} took `expr $end - $start` seconds, and resulted in ${numberOfPages} pages."

# Filter out certain file extensions
start=`date +%s`
echo "Filtering out list of file extensions for ${domain}."
bash filter_file_extensions.sh ${domainTmpFolder}${domain}_orphan_candidates
mv ${domainTmpFolder}${domain}_orphan_candidates_filtered ${domainFolder}${domain}_list_to_probe
end=`date +%s`
numberOfPages=$(wc -l ${domainFolder}${domain}_list_to_probe | awk '{print $1}')
echo "Filtering out list of file extensions for ${domain} took `expr $end - $start` seconds, and resulted in ${numberOfPages} pages."

if $dude
then
    # Perform Dynamic URL Detection
    start=`date +%s`
    initialAmount=$(wc -l ${domainFolder}${domain}_list_to_probe | awk '{print $1}')
    echo "Performing Dynamic URL Detection for ${domain}."
    bash dynamic_url_detection.sh ${domain} ${domainFolder}${domain}_list_to_probe
    mv ${domainFolder}${domain}_list_to_probe_after_link_detection ${domainFolder}${domain}_list_to_probe
    end=`date +%s`
    numberOfPages=$(wc -l ${domainFolder}${domain}_list_to_probe | awk '{print $1}')
    if [ -z "$initialAmount" ]
    then
        reduction="0"    
    elif (( $initialAmount == 0 ))
    then
        reduction="0"
    else
        reduction=$(((initialAmount*100 - numberOfPages*100) / initialAmount))
    fi
    echo "Performing Dynamic URL Detection for ${domain} took `expr $end - $start` seconds, and resulted in ${numberOfPages} pages. This is a reduction of ${reduction}%"
fi


# Check the liveness
start=`date +%s`
numberOfPages=$(wc -l ${domainFolder}${domain}_list_to_probe | awk '{print $1}')
echo "Checking status codes for ${numberOfPages} pages on ${domain}."
bash check_status_codes.sh ${domainFolder}${domain}_list_to_probe
end=`date +%s`
echo "Checking status codes for ${numberOfPages} pages on ${domain} took `expr $end - $start` seconds."

# Extract links with status code 200
start=`date +%s`
echo "Get links with status code 200 for ${domain}."
cat ${domainTmpFolder}${domain}_status_codes | awk '$1 ~ /^200/' | awk '{print $2}' > ${domainFolder}${domain}_potential_orphans
# Make sure data is not world readable
chmod 0600 ${domainFolder}${domain}_potential_orphans
numberOfPages=$(wc -l ${domainFolder}${domain}_potential_orphans | awk '{print $1}')
end=`date +%s`
echo "Extracting links with status code 200 for ${domain} took `expr $end - $start` seconds, and resulted in ${numberOfPages} pages."

# Print empty line
echo

# Finish timing for domain
end_total=`date +%s`
echo "Done!"
echo "Total procedure for ${domain} took `expr $end_total - $start_total` seconds."


