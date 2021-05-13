import sys
from bs4 import BeautifulSoup
import re
import requests

# Keywords to check
redirect_keywords = ["top.location","http-equiv=\"refresh\"","header(\'Location:","redirect_to","writeHead(3","Redirect(","AddHeader(\"Location\"","RedirectPermanent","Object moved to","window.location","301 Moved Permanently", "302 Found"]
copyright_keywords = ["copyright", "&copy", "&#169", chr(169)]
frame_keywords = ["<iframe", "<frame", "<frameset"]
not_found_keywords = ["404 Not Found", "404 Error", "Page Not Found"]
expired_keywords = ["If you are the owner of this", "Domain expired", "website has been suspended"]

archive_page = sys.argv[1]
input_url = sys.argv[2]

# Check frame
def check_frame(page):
    # Split based on keyword
    if "<iframe" in page:
        page = page.split("<ifram", 1)[1]
    else:
        page = page.split("<fram", 1)[1]
        #print(page)
        
    # Find source
    split = page.split("src=")
    
    link=""
    links = []
    # If multiple, pick first
    if len(split) > 1:
        for spl in split[1:]:
            link = spl.split("\"")[1]
            links.append(link)
    else:
        print("NoSrc /")
        exit()
    
    parsed_links = []    
    for link in links:
        if link[:4] != "http":
            if link[0] != '/':
                link = '/' + link
            link = url + link
        parsed_links.append(link)
        
    link = parsed_links[0]
    count = 1
    
    looking = True
    while looking:
        try:
            r = requests.get(link, allow_redirects=True)
            looking = False
        except Exception as e:
            if count < len(parsed_links):
                link = parsed_links[count]
                count += 1
            else:
                error = str(e).split()
                print("Error " + "".join(error))
                exit()
        
            
    html = r.text
    soup = BeautifulSoup(html, 'html.parser')
    check_page(soup)

# Check a page
def check_page(soup):
    soup_str = str(soup).lower()

    # Check for copyright
    copyright = ""
    found_copyright=False
    for keyword in copyright_keywords:
        if keyword.lower() in soup_str:
            found_copyright = True
            split = soup_str.split(keyword.lower())
            copyright += split[0][-50:]
            copyright += split[1][:50]

            if "2020" in copyright:
                print("UpToDate 2020")
                exit()
            elif "2021" in copyright:
                print("UpToDate 2021")
                exit()
    # Find dates next to copyright statement
    if found_copyright:
        nums = list(map(int, re.findall(r'\d+', copyright)))
        year = "/"
        if nums:
            year = max(nums)
        print("MightBeOld " + str(year))
        exit()
        
    # Check for redirect
    for keyword in redirect_keywords:
        if keyword.lower() in soup_str:
            print("Redirect " + keyword.split()[0])
            exit()
        
    # Check for frames
    for keyword in frame_keywords:
        if keyword.lower() in soup_str:
            check_page(soup_str)
            exit()
            
    # Check for 404 Not Found
    for keyword in not_found_keywords:
        if keyword.lower() in soup_str:
            print("NotFound " + keyword.split()[0])
            exit()  
    
    # Check if expired
    for keyword in expired_keywords:
        if keyword.lower() in soup_str:
            print("Expired /")
            exit() 
    
    for s in soup.select('script'):
        s.extract()

    content = soup.get_text().lower()
    content_list = re.findall(r"[\w']+", content)
    
    
    # Check if potential boilorplate
    if len(content_list) < 5:
        print("Boilerplate " + str(len(content_list)))
        exit()
        
    print("Nothing /")
    exit()
    
    
# Look first for potential redirect
try:
    html = open(archive_page, 'r')
    soup = BeautifulSoup(html, 'html.parser', from_encoding='utf-8')
    page = str(soup).lower()
    

    followed=False
    counts=0
    
    # While a redirect is to be found, follow it
    while ("http-equiv=\"refresh\"" in page) or ("window.location" in page):
        url="noUrl"
        
        if "http-equiv=\"refresh\"" in page:
            split = page.split("<meta")[1].split("url=")
            if len(split) > 1:
                url = split[1].split("\"")[0]
                if len(url) < 2:
                    url = split[1].split("\'")[0]
                if url[:4] != "http":
                    url = input_url + '/' + url
                
        elif "window.location" in page:
            split = page.split("window.location")[1].split("\"")
            if len(split) > 1:
                url = split[1]
                if url[:4] != "http":
                    url = input_url + '/' + url
            else:
                split = page.split("window.location")[1].split("\'")
                if len(split) > 1:
                    url = split[1]
                    if url[:4] != "http":
                        url = input_url + '/' + url
                
        if url != "noUrl":
            r = requests.get(url, allow_redirects=True, timeout=(2, 300))
            soup = BeautifulSoup(r.content, 'html.parser', from_encoding='utf-8')
            page = str(soup).lower()
        else:
            break

        counts+=1
        
        followed=True
            
        if counts == 20:
            break
            

    if counts == 20:
        print("RedirectOverflow /")
        exit()
        
except Exception as e:
    error = str(e).split()
    print("Error " + "".join(error))
    exit()



try:
    check_page(soup)
except Exception as e:
    error = str(e).split()
    print("Error " + "".join(error))
    exit()
    


