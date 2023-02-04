import json
import math
import os
import sys

batch_size = 1000
input_folder = sys.argv[1]
output_folder = os.path.join("..", "batches")

with open("CrateList.json") as f:
    raw_crates = json.load(f)

crates = [crate["Package"] for crate in raw_crates["crates"]]

batch_count = math.ceil(len(crates) / batch_size)
print(f"{batch_count} batches")

# for each batch, move its crates into a new folder with only that batch
for i in range(batch_count):
    start = i * batch_size
    end = start + batch_size
    batch = crates[start:end]
    print(f"Batch {i + 1} of {batch_count} ({len(batch)} crates)")

    # create a new folder for this batch
    batch_name = f"batch-{i + 1:02d}"
    batch_path = os.path.join(output_folder, batch_name, "rust-corpus")
    os.makedirs(batch_path, exist_ok=True)

    # move each crate into the new folder
    for crate in batch:
        folder_name = crate["name"] + "-" + crate["version"]
        folder = os.path.join(input_folder, folder_name)
        if not os.path.exists(folder):
            continue
        print(f"Moving {folder_name}...")
        os.rename(folder, os.path.join(batch_path, folder_name))
