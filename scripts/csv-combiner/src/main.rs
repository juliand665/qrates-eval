// this program reads in csv files and combines them into one.
// these csv files may contain duplicates, as recognized by their crate column
// the files are very large, so we can't load them into memory at once.

use std::fs::{self, File};
use std::path::Path;
use std::{collections::HashSet, env};

fn main() {
    let args: Vec<_> = env::args().collect();
    let start: i32 = args[1].parse().unwrap();
    let end: i32 = args[2].parse().unwrap();

    let batches_folder = Path::new("../../batches");
    let output_folder = Path::new("combined");
    fs::create_dir_all(output_folder).unwrap();

    let csv_names = ["all_calls.csv", "cross_crate_calls.csv"];
    let mut csv_writers: Vec<_> = csv_names
        .iter()
        .map(|name| File::create(output_folder.join(name)).unwrap())
        .map(csv::Writer::from_writer)
        .collect();

    let mut seen_crates = HashSet::<String>::new();
    for batch_num in start..=end {
        let mut new_crates: HashSet<String> = HashSet::new();

        let batch_name = format!("batch-{:02}", batch_num);
        let batch_folder = batches_folder
            .join(batch_name)
            .join("reports")
            .join("resolved-calls");
        println!(
            "Processing batch {:?}...",
            batch_folder.canonicalize().unwrap()
        );
        for (csv_name, writer) in csv_names.iter().zip(csv_writers.iter_mut()) {
            let file = File::open(batch_folder.join(csv_name)).unwrap();
            let mut reader = csv::Reader::from_reader(file);
            for record in reader.records() {
                let record = record.unwrap();
                let crate_name = record.get(5).unwrap();
                if seen_crates.contains(crate_name) {
                    continue;
                }
                new_crates.insert(crate_name.to_string());
                writer.write_record(record.iter()).unwrap();
            }
        }

        seen_crates.extend(new_crates);
    }

    println!("Done! {} crates encountered.", seen_crates.len());
}
