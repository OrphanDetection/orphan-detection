import pandas as pd
import sys

# Get URLs
urls = sys.argv[1]

# Read data
df = pd.read_csv(urls, names=['url', 'size'], delimiter=' ')
                 
start_len = len(df)
to_remove = []
tmp_remove = []
current_domain = ""
current_size = 0
epsilon = 5

# Loop over entries, ordered by size
for index, row in df.sort_values(by=['size']).iterrows():
    # If size is within reasonable similarity to previous size, add to discard list
    if row['size'] <= current_size + epsilon:
        tmp_remove.append(index)
        current_size = row['size']
        continue
    # Write out current discard list and continue procedure
    else:
        if len(tmp_remove) >= 2:
            to_remove += tmp_remove
        tmp_remove = []
        current_size = row['size']
        tmp_remove.append(index)


# Remove all entries that need to be discarded
filtered = df[~df.index.isin(to_remove)].sort_values(by=['url'])
# Write out results
filtered.to_csv(urls + "_filtered", index=False, sep=" ", header=False)

# Calculate the reduction percentage
end_len = len(filtered)
reduction = 100 - ((end_len/start_len) * 100)

print("Reduction of {:.2f}%".format(reduction))
