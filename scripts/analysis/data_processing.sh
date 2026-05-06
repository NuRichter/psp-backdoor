#!/bin/bash

# Define log files and output files
SOCKET_LOG="data/logs/socket_logs.txt"
SYSTEM_LOG="data/logs/system_logs.log"
PROCESSED_DATA="data/processed/analyzed_data.csv"
CLEANED_LOGS="data/processed/cleaned_logs.log"

# Clear previous processed data if exists
> "$PROCESSED_DATA"
> "$CLEANED_LOGS"

# Function to extract and process socket logs
process_socket_logs() {
    while IFS= read -r line; do
        # Extract timestamp, log level, and message from the socket log
        TIMESTAMP=$(echo "$line" | grep -oP '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}')
        LEVEL=$(echo "$line" | grep -oP '(INFO|ERROR) - ')
        MESSAGE=$(echo "$line" | cut -d' ' -f5-)

        # Check if the message contains JSON data
        if echo "$MESSAGE" | jq . > /dev/null 2>&1; then
            DEVICE_ID=$(echo "$MESSAGE" | jq -r '.device_id')
            COMMAND=$(echo "$MESSAGE" | jq -r '.command')

            if [ "$COMMAND" == "connect" ]; then
                echo "$TIMESTAMP,Device Connected,$DEVICE_ID" >> "$PROCESSED_DATA"
            elif [ "$COMMAND" == "disconnect" ]; then
                echo "$TIMESTAMP,Device Disconnected,$DEVICE_ID" >> "$PROCESSED_DATA"
            else
                DATA=$(echo "$MESSAGE" | jq -r '.data')
                echo "$TIMESTAMP,Sensor Data,$DATA" >> "$PROCESSED_DATA"
            fi
        elif [[ "$MESSAGE" == *"Received data from"* ]]; then
            CLIENT_ADDR=$(echo "$MESSAGE" | grep -oP '\(\d+\.\d+\.\d+\.\d+:\d+\)')
            RECEIVED_DATA=$(echo "$MESSAGE" | cut -d':' -f4-)
            echo "$TIMESTAMP,Data Received,$CLIENT_ADDR,$RECEIVED_DATA" >> "$PROCESSED_DATA"
        fi
    done < "$SOCKET_LOG"
}

# Function to clean and process system logs
process_system_logs() {
    while IFS= read -r line; do
        # Extract timestamp, log level, and message from the system log
        TIMESTAMP=$(echo "$line" | grep -oP '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3}')
        LEVEL=$(echo "$line" | grep -oP '(INFO|ERROR) - ')
        MESSAGE=$(echo "$line" | cut -d' ' -f5-)

        # Check for specific event patterns
        if [[ "$MESSAGE" == *"Event"* ]]; then
            EVENT_DATA=$(echo "$MESSAGE" | cut -d'-' -f2-)
            echo "$TIMESTAMP,Event,$EVENT_DATA" >> "$CLEANED_LOGS"
        fi
    done < "$SYSTEM_LOG"
}

# Main processing function
main() {
    process_socket_logs
    process_system_logs
    echo "Data processing completed."
}

# Run main function
main
