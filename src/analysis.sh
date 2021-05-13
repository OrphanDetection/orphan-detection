#!/bin/bash
domain=$1
date=$2
potential_orphans="../Data/Results/${domain}/${domain}_potential_orphans"
domainTmpFolder="../Data/tmp/${domain}/"

# Filter on page size
start=`date +%s`
echo "Filtering on page size for ${domain}"
bash retrieve_page_size.sh $potential_orphans $domain
python3 filter_same_size.py ${domainTmpFolder}${domain}_with_size
end=`date +%s`
echo "Filtering on page size for ${domain} took `expr $end - $start` seconds."

# Get last seen date in the archive
start=`date +%s`
echo "Looking up last seen dates of ${domain} urls in archive data."
bash get_last_seen_date.sh ${domainTmpFolder}${domain}_with_size_filtered $domain $date
end=`date +%s`
echo "Looking up last seen dates of ${domain} took `expr $end - $start` seconds."

# Perform fingerprint comparison
start=`date +%s`
echo "Creating and comparing fingerprints for ${domain}"
bash compare_fingerprints.sh ${domainTmpFolder}${domain}_with_dates
end=`date +%s`
echo "Creating and comparing fingerprints for ${domain} took `expr $end - $start`. seconds"

# Calculate orphan score and filter urls based on orphan score
start=`date +%s`
echo "Calculating orphan score and filtering urls for ${domain}"
python3 orphan_score.py ${domainTmpFolder}${domain}_with_dates_after_fingerprint $domain "../Data/Input/orphan_score_parameters/default"
end=`date +%s`
echo "Calculating orphan score and filtering urls for ${domain} took `expr $end - $start` seconds."

# Analyze page type
start=`date +%s`
echo "Analyzing pages for ${domain}"
bash page_analysis.sh ${domainTmpFolder}${domain}_after_orphan_score_filter $domain
end=`date +%s`
echo "Analyzing pages for ${domain} took `expr $end - $start` seconds."

