#!/bin/bash

# Define the input and output directories
INPUT_DIR="data/logs"
OUTPUT_DIR="data/processed"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Function to clean and compress logs
clean_and_compress_logs() {
    local log_file="$1"
    local base_name=$(basename "$log_file" .txt)
    local cleaned_log="$OUTPUT_DIR/$base_name.cleaned.log"
    local compressed_log="$OUTPUT_DIR/$base_name.gz"

    # Clean the log file by removing unneeded lines
    grep -vE 'DEBUG|TRACE' "$log_file" > "$cleaned_log"

    # Compress the cleaned log file
    gzip "$cleaned_log"
}

# Process all log files in the input directory
process_logs() {
    for log_file in "$INPUT_DIR"/*.txt; do
        if [ -f "$log_file" ]; then
            echo "Processing $log_file"
            clean_and_compress_logs "$log_file"
        else
            echo "No log files found in $INPUT_DIR."
        fi
    done
}

# Main function to control the flow
main() {
    process_logs
    echo "Log cleaning and compression completed."
}

# Run main function
main
