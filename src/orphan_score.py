import pandas as pd
import sys

# Get data, domain name, and parameters
input_data = sys.argv[1]
domain = sys.argv[2]
parameters = sys.argv[3]

# Parse parameters
params = ""
with open(parameters, "r") as p:
    for line in p:
        params = line.rstrip("\n")
    
param_values = params.split(",")

age_weight = float(param_values[0])
sim_weight = float(param_values[1])
cutoff = float(param_values[2])

# Extract year from timestamp
def get_last_year(c):
    return str(c['last_seen'])[:4]

# Compute the orphan score for an entry
def compute_orphan_score(c, ws, wa):
    sim = float(c['sim_score']) * 23
    age = 2020-int(c['last_year'])
    return (sim*ws + age*wa) / 23
    
# Read in data
df = pd.read_csv(input_data, delimiter=" ", names=['url', 'size', 'last_seen', 'sim_score'])
# Extract last year from timestamp
df['last_year'] = df.apply(get_last_year, axis=1)
# Filter out pages that were not HTML
df=df[df['sim_score'] != 'NoHTML']

# Check if not all pages are removed
if len(df) > 0:
    # Calculate orphan score
    df['orphan_score'] = df.apply(compute_orphan_score, ws=sim_weight, wa=age_weight, axis=1)

    # Filter out pages with orphan score lower than the cutoff
    df=df[df['orphan_score'] >= cutoff]

# Reduce dataframe
df = df[['url', 'size', 'last_year']]

# Save results
df.to_csv("../Data/tmp/" + domain + "/" + domain + "_after_orphan_score_filter", index=False, header=False, sep=' ')
