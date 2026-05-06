# Investigation Report for PSP-Backdoor Project

## Introduction

This report details the findings and analysis conducted during the PSP-Backdoor project aimed at identifying backdoors on enemy devices, injecting malware, and exfiltrating data in an undetected manner.

## Methodology

1. **Initial Scanning:** Utilized `scan_backdoors.py` and `port_scanner.bash` to identify potential backdoors.
2. **Socket Analysis:** Used `socket_analysis.py` and `data_processing.sh` to analyze network communications for signs of backdoor activity.
3. **Data Collection:** Employed `data_collector.py`, `file_downloader.sh`, and `network_sniffer.bash` to gather relevant data from compromised systems.
4. **Malware Injection:** Injected malware using scripts in the `malware/` directory, including ransomware and viruses.

## Findings

1. **Identified Backdoors:**

   - Socket-based backdoor on port 4455.
   - Hidden service running on port 8080.
2. **Malware Injection Success:**

   - Successfully injected `ransomware.py` onto target devices without detection.
   - Deployed `virus.py` to cause further system instability and data corruption.
3. **Data Exfiltration:**

   - Collected sensitive data from compromised systems using `file_downloader.sh`.
   - Sniffed network traffic to capture additional valuable information.

## Recommendations

1. **Enhance Detection Mechanisms:** Implement more sophisticated detection methods to identify hidden backdoors.
2. **Strengthen Security Measures:** Apply security patches and updates regularly to mitigate vulnerabilities.
3. **Monitor Network Traffic:** Continuously monitor network traffic for unusual activity indicative of backdoor usage or malware injection.

## Conclusion

The PSP-Backdoor project successfully identified multiple backdoors on enemy devices, injected malware to cause significant disruption, and exfiltrated valuable data in an undetected manner. The findings highlight the importance of robust cybersecurity measures in preventing such breaches.
