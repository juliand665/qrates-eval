# Scripts

These scripts were useful to me in wrangling the large amount of data produced by the compilation process.

I started by running qrates to fetch all crates in order of popularity (at the time just over 100k, so i fetched the top 100k) `cargo run --release -- init 100000`.
I then copied this CrateList.json over to a dedicated machine and ran `cargo run --release -- compile-batched`, which ended up taking several weeks for this amount of crates.
As this got closer to filling up the machine's disk, I copied over the extracted output to a local machine and cleared it for future batches.

On the local machine, I soon realized that this data was much easier to work with when grouped by batch, so I wrote a python script to restore that grouping based on the CrateList.json: `separate_batches.py`.

As my local machine was Windows, and WSL2 file system performance is reduced for files outside its virtual disk, I used PowerShell from this point onwards.
Because my disk was getting too full, I created a powershell script to iterate over the separated batches and compress each one's compilation output into a zip, compressing by a factor of around 5x: `zip_data.ps1`.

After this, I had to process each batch, using Qrates to create a database and run the query I was interested in.
`process_batches.ps1` loops over the batches in a given range, processing them all by calling `create_database.ps1`, which only concerns itself with one batch at a time.
It uploads the zipped data to a remove machine with the same OS and architecture as the one used to compile the batches (this is required to match).
It then runs `server_process.sh`, which should be uploaded there first.
This shell script unzips the compiled output, builds the database, runs the query, and zips up the database for fast transfer back.
The PowerShell script then downloads this zip and the query output into the batch's folder.

Finally, the CSV files produced by the query for each batch need to be combined.
This is the most domain-specific step—the important thing to note is that the database includes data from all dependencies of the crates in each batch in addition to the ones directly included in it.
As such, I put together a Rust binary, `csv-combiner`, that goes through each CSV and appends only the data from crates not seen in previous batches to a final combined CSV.

And that's all it takes!
