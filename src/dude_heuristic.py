import operator
import sys


RESULT = "../Data/Results/"
TEMP = "../Data/tmp/"
LARGE_LINK_LEN_THRESHOLD = 0
large_link_count = 0
short_prefix_cutoff = 0


# Generate a link
def generate_link(counts, max_len, len_count, sitemap_len):
    # Based on character counts, try to generate a link based on
    # the most used character for each position.
    generated_link = max(counts[0].items(), key=operator.itemgetter(1))[0]
    for i in range(1, max_len):
        char = max(counts[i].items(), key=operator.itemgetter(1))[0]
        generated_link += max(counts[i].items(), key=operator.itemgetter(1))[0]
    
    # Get the average link length of all links on the page    
    average = len_count // sitemap_len
    # Cut the generated link down to the average link length.
    # This will be our guess for the prefix.
    prefix = generated_link[:average]
    
    return prefix


# Count the charactre frquency at each position
def count_char_occurrance(links, max_len):
    position_count = [0 for i in range(max_len)]
    counts = {}
    
    # Count the occurrance of charcters at each position in the link
    for link in links:
        for i, c in enumerate(link):
            if i in counts:
                if not c in counts[i]:
                    counts[i][c] = 1
                    position_count[i] += 1
                else:
                    counts[i][c] += 1
            else:
                counts[i] = {c:1}
                position_count[i] += 1
                
    return position_count, counts


# Find the shortest prefix that yields a good filter    
def shorten_prefix(prefix, sitemap, cutoff_perc):
    bl_count = []

    sitemap_len = len(sitemap)
    potential_blacklist = []
    whitelist = []
    
    cutoff = cutoff_perc * sitemap_len
    # For each link on the page, check all links that match the prefix and add to blacklist.
    for link in sitemap:
        if prefix in link:
            potential_blacklist.append(link)       
        else:
            whitelist.append(link)
            
    bl_count.append(len(potential_blacklist))
    
    
    while len(potential_blacklist) < cutoff and len(potential_blacklist) != sitemap_len:
        prefix = prefix[:-1]
        potential_blacklist = []
        whitelist = []
        # For each link on the page, check all links that match the prefix and add to blacklist.
        for link in sitemap:
            if prefix in link:
                potential_blacklist.append(link)
            else:
                whitelist.append(link)
                
        bl_count.append(len(potential_blacklist))
                
    return prefix, potential_blacklist, whitelist, bl_count
    


# Goes through all links on a page and tries to generate
# the prefix of the potentialy generated links.           
def check_for_generated_links_new(sitemap, domain, domain_len, popularity_cutoff):
    max_len = 0
    len_count = 0
    large_links = []
    sitemap_len = len(sitemap)
    for link in sitemap:
        link_len = len(link)
        
        # Keep track of all large links
        # 8 is to account for https://
        if link_len > LARGE_LINK_LEN_THRESHOLD + domain_len + 8:
            large_links.append(link)
            
        len_count += link_len
        
        # Save the maximal link length
        if link_len > max_len:
            max_len = link_len
    
    # If there are less than 5 large links, don't bother checking,
    # they are probably not generated.
    if len(large_links) <= large_link_count:
        return False
            
    
    # Count character frequency
    position_count, counts = count_char_occurrance(large_links, max_len)
    
    # Generate a link
    generated_link = generate_link(counts, max_len, len_count, sitemap_len)
    
    # Determine the prefix
    prefix, potential_blacklist, whitelist, bl_count = shorten_prefix(generated_link, sitemap, popularity_cutoff)
    
    # When prefix is too small, abort
    # 8 is to account for https:// and 10 is a chosen offset   
    if len(prefix) < domain_len + 8 + short_prefix_cutoff:
        # If no pages remain, program is done
        if not whitelist:
            return False
        
        # Run heuristic on pages that do not contain prefix
        go = check_for_generated_links_new(whitelist, domain, domain_len, popularity_cutoff)
        
        # Store whether prefix was found (and hence, the list of pages was altered)
        change = go
        
        # Loop till no more prefixes are found  
        while go:
            sitemap = []
            # Read in links
            with open(RESULT + domain + '/whitelist', "r") as links:
                for line in links:
                    link = line.rstrip("\n")
                    sitemap.append(link)
                
            
            # Run the heuristic and store whether prefix is found or not
            go = check_for_generated_links_new(sitemap, domain, domain_len, popularity_cutoff)
        
        
        
        # IF a new, valid, prefix was found,
        # add the excluded links again to the list of orphan pages.
        # If no new prefix was found, the excluded pages are still in the file
        if change:
            with open(RESULT + domain + '/whitelist', 'a') as f:
                for item in potential_blacklist:
                    f.write("%s\n" % item)
            
        return False
    
    
    # Write out remaining orphan pages    
    with open(RESULT + domain + '/whitelist', 'w') as f:
        for item in whitelist:
            f.write("%s\n" % item)
    
    # Write out discarded orphan pages        
    with open(TEMP + domain + '/blacklist', 'a') as f:
        for item in potential_blacklist:
            f.write("%s\n" % item)
            
    return True
                        




####################
# CODE STARTS HERE #
####################


# First argument is the domain name
domain = sys.argv[1]
# Orphan pages
pages = sys.argv[2]

domain_len = len(domain)

# Read parameters
parameters = sys.argv[3]
params = ""
with open(parameters, "r") as p:
    for line in p:
        params = line.rstrip("\n")
    
param_values = params.split(",")

# Cutoff to decide how many of the pages need to contain the found prefix
popularity_cutoff = float(param_values[0])
# Length of what is considered a short prefix
short_prefix_cutoff = int(param_values[1])
# Length of what is considered a large link
LARGE_LINK_LEN_THRESHOLD = int(param_values[2])
# Amount of large links that need to be among the links
large_link_count = int(param_values[3])
        
# Loop till no more prefixes are found        
go = True
while go:
    sitemap = []
    # Read in links
    with open(pages, "r") as links:
        for line in links:
            link = line.rstrip("\n")
            sitemap.append(link)
    
    # Run the heuristic and store whether a prefix was found
    go = check_for_generated_links_new(sitemap, domain, domain_len, popularity_cutoff)
        
        
