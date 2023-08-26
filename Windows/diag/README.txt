diag.cmd - is a Diagnostic tool for any Windows version. Run the script and it will produce a hostname.txt file with valuable information about your system.

Change some values in the first section to fit your needs and open for icmp and DNS to Internet as the script will both Ping and do nslookups.
The idea is that the script will check that your host can resolve and reach both internal and external destinations.

If allowed the script will tell you your external IP, this requirers external DNS.

At this stage the script has some hardcoded text for the last sections:
Check Point VPN client
Check Point SSL VPN

Both these sections can easily be disabled at the first config section, but if you want to use them change the content in them.
