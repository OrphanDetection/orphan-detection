#!/bin/bash

links=$1
export tmp="../Data/tmp/comp_test/"
mkdir -p $tmp

compare_pages () {
    line=$1
    # Extract parameters from input
    url=$(echo $line | awk '{print $1}')
    last_seen_date=$(echo $line | awk '{print $3}')

    # Handle url filenames
    current_page=${tmp}$(echo ${url} | md5sum | awk '{print $1}')
    last_archive_page=${tmp}$(echo ${url}${last_seen_date} | md5sum | awk '{print $1}')
    

    # Download pages
    curl -s --connect-timeout 2 --max-time 300 "$url" > "$current_page"
    # Add 'id_' at the end of the date to remove archive code (such as banner etc)
    curl -s --connect-timeout 2 --max-time 300 "https://web.archive.org/web/${last_seen_date}id_/${url}" > "$last_archive_page"
    

    # Get filetype of current page
    filetype_current=$(file -i $current_page | awk '{print $2}')
    
    # If current page is not html, don't check
    if [ $filetype_current == 'text/html;' ]
    then
        # Get encoding of the current page
        enc_current=$(file -i $current_page | awk '{print $3}')
        enc_current="${enc_current##*=}"
        
        # If first page is not encoded in utf-8, convert to utf-8
	    if [ $enc_current != "utf-8" ]
	    then
	        iconv -f $enc_current -t utf-8 $current_page > ${current_page}_tmp && mv ${current_page}_tmp $current_page
	    fi
	    
	    # COMPARISON WITH LAST SEEN VERSION
	    # ----------------------------------
	    
	    # Get filetype
	    filetype_last=$(file -i $last_archive_page | awk '{print $2}')
	    # If not html, don't check
        if [ $filetype_last == 'text/html;' ]
        then
            # Get encoding
	        enc_last=$(file -i $last_archive_page | awk '{print $3}')
    	    enc_last="${enc_last##*=}"
    	    
    	    # If last seen page is not encoded in utf-8, convert to utf-8
	        if [ $enc_last != "utf-8" ]
	        then
	            iconv -f $enc_last -t utf-8 $last_archive_page > ${last_archive_page}_tmp && mv ${last_archive_page}_tmp $last_archive_page
	        fi
	        
	        # Create and compare fingerprints
	        result_last=$(python3 simhash.py $current_page $last_archive_page)
	        
	        # Remove the donwloaded page
	        rm $last_archive_page
	    else
	        result_last="NoHTML"
	    fi
	    # Remove donwloaded page
	    rm $current_page
    else
	    result_last="NoHTML"
    fi
    
    echo "$line $result_last"
}
export -f compare_pages

cat $links | parallel -j5 compare_pages > ${links}_after_fingerprint

