#!/bin/bash
links="$1"

# Filter out certain file extensions
grep -P '^(?:(?!\.(jpg|gif|css|svg|png|pdf|jpeg|mov|avi|mpg|wmv|mp4|ttf|woff|eot|js|ico|mp3|ogg|webm|webp|tiff|psd|bmp|heif|indd|ai|eps|jpe|jif|jfif|jfi|tif|dib|heic|ind|indt|jp2|j2k|jpf|jpx|jpm|mj2|svgz|m4a|m4v|f4v|f4a|m4b|m4r|f4b|3gp|3gp2|3g2|3gpp|3gpp2|oga|ogv|ogx|wma|flv|mp2|mpeg|mpe|mpv|m4p|qt|swf)).)*$' $links > ${links}_filtered
# Make sure data is not world readable
chmod 0600 ${links}_filtered 

