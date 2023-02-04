#!/bin/bash

source .cargo/env
cd workspace
rm -rf rust-corpus database reports database.zip
unzip rust-corpus.zip
mv batch-*/rust-corpus ./ # whoops
rm -rf batch-*
(cd ../qrates && cargo run --release update-database)
(cd ../qrates && cargo run --release query resolved-calls)
zip -r database.zip database
