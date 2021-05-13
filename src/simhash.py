from bs4 import BeautifulSoup
import re
from nltk import ngrams
import pyhash
from scipy.spatial import distance
import sys

NGRAM_SIZE = 8

# Initiate hash function
hasher = pyhash.fnv1a_64()

# Get system arguments
file1 = sys.argv[1]
file2 = sys.argv[2]

# Open html files
html1 = open(file1, 'r')
html2 = open(file2, 'r')

try:
    if "you have sent too many requests in a given amount of time" in html2:
        print("RateLimit")
        exit(0)

    # Interpret html pages
    soup1 = BeautifulSoup(html1, 'html.parser', from_encoding='utf-8')
    soup2 = BeautifulSoup(html2, 'html.parser', from_encoding='utf-8')

    # Fiilter out all tags and extract only the text
    content1 = soup1.get_text()
    content2 = soup2.get_text()

    # Extract all words and make lowercase
    content_list1 = re.findall(r"[\w']+", content1.lower())
    content_list2 = re.findall(r"[\w']+", content2.lower())
except Exception as e:
    print("Error")
    exit(0)

# Function to create the fingerprint
def make_fingerprint(words):
    # Divide text into ngrams/shingles
    shingles = list(ngrams(words, NGRAM_SIZE))

    hashgrams = []
    # Hash each of the ngrams/shingles
    for gram in shingles:
        hashgrams.append(hasher(''.join(gram)))

    fingerprint = [0 for i in range(64)]
    # Create fingerprint based on the ngrams/shingles
    for gram in hashgrams:
        # Convert text to binary
        binary = bin(gram)
        # Get the amount of bits (which excludes the leading 0's)
        bin_len = len(binary) - 2
        bin_str = ""
        # Add the missing leading 0's to make all hashes 64 bit
        for _ in range(64-bin_len):
            bin_str += '0'
        bin_str += binary[2:]

        # For each bit in the ngram/shingle,
        # if the bit is one, increment its index in the fingerprint by one,
        # if the bit is 0, decrement its index in the fingerprint by 1.
        for i in range(64):
            if bin_str[i] == '1':
                fingerprint[i] += 1
            else:
                fingerprint[i] -= 1
    
    # For each index in the fingerprint,
    # if the value is greater than 0, convert to 1,
    # else convert to 0
    for i in range(64):
        if fingerprint[i] > 0:
            fingerprint[i] = 1
        else:
            fingerprint[i] = 0
    
    return fingerprint

try:
    # Make fingerprint of both pages it's  content
    fingerprint1 = make_fingerprint(content_list1)
    fingerprint2 = make_fingerprint(content_list2)

    #print(''.join(str(x) for x in fingerprint1))
    #print(''.join(str(x) for x in fingerprint2))

    # Calculate Hamming distance between fingerprints
    hamming_distance = distance.hamming(fingerprint1, fingerprint2)

    # Similarity score
    similarity = 1-hamming_distance

    print(similarity)
except Exception as e:
    print("Error")
    exit(0)    

