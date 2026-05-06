# Research Notes for PSP-Backdoor Project

## Initial Scanning Techniques

- **Port Scanning:** Used `port_scanner.bash` to identify open ports that may host backdoors. Focused on non-standard ports commonly used by attackers (e.g., 4455, 8080).
- **Service Detection:** Analyzed services running on identified ports using tools like Nmap for further investigation.

## Socket Analysis

- **Network Traffic Monitoring:** Employed `socket_analysis.py` to monitor network traffic and identify patterns indicative of backdoor usage.
- **Data Processing:** Utilized `data_processing.sh` to filter and analyze collected data, focusing on anomalies that may signal backdoor activity.

## Data Collection Tools

- **File Downloader:** Developed `file_downloader.sh` to automatically download files from compromised systems for analysis.
- **Network Sniffer:** Created `network_sniffer.bash` to capture network traffic for detailed examination of communications between attacker and target.

## Malware Injection Strategies

- **Ransomware Deployment:** Tested the effectiveness of deploying `ransomware.py` on various systems, ensuring it encrypts data without detection.
- **Virus Introduction:** Injected `virus.py` to cause system instability and facilitate further exploitation, verifying its impact.

## Backdoor Techniques

- **Socket-based Backdoors:** Investigated the use of standard TCP/UDP sockets for backdoor communication, highlighting their effectiveness in bypassing security measures.
- **Hidden Services:** Explored the deployment of hidden services on non-standard ports to obscure backdoor presence and facilitate data exfiltration.

## Security Recommendations

1. **Enhanced Detection:** Implement more sophisticated detection mechanisms to identify hidden backdoors effectively.
2. **Regular Updates:** Apply security patches and updates regularly to protect against known vulnerabilities.
3. **Continuous Monitoring:** Monitor network traffic continuously for signs of backdoor activity or malware injection.
4. **Persistence Mitigation:** Develop strategies to counteract persistence mechanisms used by attackers to maintain long-term access.

## Additional Resources

- [AMD Socket 5 Documentation](references/amd_socket_5.pdf) - Provides detailed information on socket-based communication methods.
- [Backdoor Techniques Reference](references/backdoor_techniques.txt) - Summarizes various backdoor techniques and their implementation strategies.
