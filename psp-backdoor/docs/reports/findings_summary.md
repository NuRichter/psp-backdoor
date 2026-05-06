# Summary of Findings from PSP-Backdoor Project

## Identified Backdoors

- **Socket-based Backdoor:** Detected on port 4455, allowing unauthorized access to target systems.
- **Hidden Service:** Found running on port 8080, used for data exfiltration.

## Malware Injection Success

- **Ransomware (`ransomware.py`):** Successfully deployed without detection, encrypting sensitive files on the compromised system.
- **Virus (`virus.py`):** Injected to cause system instability and facilitate further exploitation.

## Data Exfiltration

- Utilized `file_downloader.sh` to collect critical data from compromised systems.
- Employed `network_sniffer.bash` to capture additional sensitive information over network traffic.

## Recommendations

1. **Improve Detection:** Develop advanced detection mechanisms to identify hidden backdoors effectively.
2. **Strengthen Security:** Regularly apply security patches and updates to protect against vulnerabilities.
3. **Continuous Monitoring:** Monitor network traffic continuously for signs of backdoor activity or malware injection.
