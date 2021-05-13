#!/bin/bash
export tmp="../Data/tmp/pages/"
mkdir -p $tmp
links=$1
domain=$2

# Analyze pages
check_links () {
    # Get URL and date from input
    link=$(echo $1 | awk '{print $1}')
    date=$(echo $1 | awk '{print $3}')

    # Filename based on URL and date
    page=${tmp}$(echo ${link}${date} | md5sum | awk '{print $1}')

    # Download page
    curl -sL --connect-timeout 2 --max-time 300 "${link}" > "$page"

    # Get file encoding of page
    encoding=$(file -i $page | awk '{print $3}')
    encoding="${encoding##*=}"

    # Check encoding and convert when needed
    if [ $encoding != "utf-8" ]
    then
	iconv -f $encoding -t utf-8 $page > ${page}_tmp && mv ${page}_tmp $page
    fi

    # Check content of page
    check=$(python3 check_page.py $page $link)

    # Write out results
    echo "$1 $check"
    
    # Remove downloaded page
    rm $page
}
export -f check_links

cat $links | parallel -j5 check_links > "../Data/Results/${domain}/"${domain}_analysis_results
