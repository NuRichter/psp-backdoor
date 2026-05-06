#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

INTERFACE=$(ip link show | awk -F': ' '/state UP/{print $2}' | head -n 1)
OUTPUT_DIR="/var/log/network_sniffer"
LOG_FILE="$OUTPUT_DIR/network_capture_$(date +%Y%m%d_%H%M%S).pcap"

mkdir -p "$OUTPUT_DIR"

if [ ! -d "$OUTPUT_DIR" ]; then
    echo "Failed to create output directory. Exiting."
    exit 1
fi

TCPDUMP_OPTS="-i $INTERFACE -w $LOG_FILE -s 65535"
FILTERS=""
IP_ADDRESSES=""

function parse_arguments {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --interface)
                INTERFACE="$2"
                shift 2
                ;;
            --filter)
                FILTERS="$2"
                shift 2
                ;;
            --ip-addresses)
                IP_ADDRESSES="$2"
                shift 2
                ;;
            *)
                echo "Unknown parameter passed: $1"
                exit 1
        esac
    done
}

function validate_ip_addresses {
    IFS=',' read -ra ADDR <<< "$IP_ADDRESSES"
    for ip in "${ADDR[@]}"; do
        if ! [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "Invalid IP address format: $ip"
            exit 1
        fi
    done
}

function construct_tcpdump_filter {
    FILTER=""
    if [ -n "$FILTERS" ]; then
        IFS=',' read -ra FILT <<< "$FILTERS"
        for filt in "${FILT[@]}"; do
            FILTER="$FILTER and $filt"
        done
    fi

    if [ -n "$IP_ADDRESSES" ]; then
        IFS=',' read -ra ADDR <<< "$IP_ADDRESSES"
        for ip in "${ADDR[@]}"; do
            FILTER="$FILTER or host $ip"
        done
    fi

    if [ -n "$FILTER" ]; then
        TCPDUMP_OPTS="$TCPDUMP_OPTS '$FILTER'"
    fi
}

function start_sniffing {
    tcpdump $TCPDUMP_OPTS 2>&1 | tee "${LOG_FILE%.pcap}.log"
    echo "Sniffing started on interface: $INTERFACE with filters: $FILTERS"
}

function stop_sniffing {
    pkill -f "$LOG_FILE"
    echo "Sniffing stopped. Data saved to: $LOG_FILE"
}

function main {
    parse_arguments "$@"
    validate_ip_addresses
    construct_tcpdump_filter
    start_sniffing
}

main "$@"

trap 'stop_sniffing' SIGINT

while true; do
    sleep 1
done