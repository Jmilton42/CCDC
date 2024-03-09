#!/usr/bin/env python3

import os
import re
import sys
import json
import subprocess

# https://stackoverflow.com/questions/4417546/constantly-print-subprocess-output-while-process-is-running
def execute(command):
    output = ""
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    while True:
        nextline = process.stdout.readline().decode('utf-8')
        if nextline == '' and process.poll() is not None:
            break
        output += nextline
        sys.stdout.write(nextline)
        sys.stdout.flush()

    exitCode = process.returncode

    if (exitCode == 0):
        return output
    else:
        raise Exception(command, exitCode, output)

# Define the ports we care about
# Go from most specific to least specific
LINUX_FINGERPRINTS = [ "ubuntu 24.04", "ubuntu 22.04", "ubuntu 20.04", "ubuntu 18.04", "ubuntu 16.04", "ubuntu 14.04", "ubuntu 12.04", "debian 11", "debian 10", "debian 9", "debian 8", "fedora 34", "fedora 33", "fedora 32", "fedora 31", "fedora 30", "centos 8", "centos 7", "centos 6", "redhat 8", "redhat 7", "redhat 6", "ubuntu", "debian", "fedora", "centos", "redhat", "freebsd", "openbsd", "netbsd", "suse", "opensuse", "arch", "gentoo", "slackware", "alpine", "rhel", "linux" ]
WINDOWS_FINGERPRINTS = [ "windows server 2022", "windows server 2019", "windows server 2016", "windows server 2012", "windows server 2008", "windows server 2003", "windows 11", "windows 10", "windows 8", "windows 7", "windows vista", "windows xp", "windows 2000", "windows workstation 10", "windows workstation 8", "windows workstation 7", "windows workstation vista", "windows workstation xp", "windows workstation 2000", "windows workstation", "windows server", "microsoft", "msrpc", "ms-sql", "winrm" ]
DC_FINGERPRINTS = [ "kerberos", "ldap" ]
FTP_FINGERPRINTS = [ "proftpd", "vsftpd", "pure-ftpd", "ftp", "sftp", "ftps" ]
MAIL_FINGERPRINTS = [ "exim", "sendmail", "postfix", "dovecot", "qmail", "squirrelmail", "smtp", "pop3", "imap" ]
HTTP_FINGERPRINTS = [ "apache", "nginx", "iis", "http-proxy", "flask", "tomcat", "jboss", "weblogic", "websphere", "glassfish", "jetty", "resin", "tomee", "wildfly" ]
DB_FINGERPRINTS = [ "mysql", "mssql", "postgresql", "oracle" ]
REMOTE_FINGERPRINTS = [ "tightvnc", "realvnc", "ultravnc", "tigervnc", "nomachine", "ms-wbt-server", "ultr@vnc", "xrdp", "x11", "xorg", "rdp", "vnc", "ssh" ]

# Build the nmap command
ip = input("Enter the IP address of the target: ")
cmd = 'sudo nmap' # lazy_nmap goes here
cmd += ' -sS -sV -sC -oN nmap_out'
cmd += f" {ip}"

print(f"Running: {cmd}")

try:
    output = execute(cmd)
except Exception as e:
    print(f"Error running nmap: {e}")
    sys.exit(1)

# Parse the output
hosts = {}
current_host = None

print("*" * 50)
print("Identifying OS and services...")
print("*" * 50)

output = output.split("\n")
for line in output:
    if "Nmap scan report for" in line:
        ip = line.split(" ")[-1]
        current_host = ip
        hosts[current_host] = ""
    else:
        if current_host == None: continue
        output = hosts[current_host] + line
        hosts[current_host] = output

for host in hosts:
    windows_fingerprint_count = 0
    linux_fingerprint_count = 0
    print(f"Host: {host}")
    for windows_fingerprint in WINDOWS_FINGERPRINTS:
        if windows_fingerprint in hosts[host].lower():
            print(f"    [+] OS match: Windows ({windows_fingerprint})")
            windows_fingerprint_count += 1
    for linux_fingerprint in LINUX_FINGERPRINTS:
        if linux_fingerprint in hosts[host].lower():
            print(f"    [+] OS match: Linux ({linux_fingerprint})")
            linux_fingerprint_count += 1
    for dc_fingerprint in DC_FINGERPRINTS:
        if dc_fingerprint in hosts[host].lower():
            print(f"    [+] Service: Domain Controller ({dc_fingerprint})")
    for ftp_fingerprint in FTP_FINGERPRINTS:
        if ftp_fingerprint in hosts[host].lower():
            print(f"    [+] Service: FTP ({ftp_fingerprint})")
    for mail_fingerprint in MAIL_FINGERPRINTS:
        if mail_fingerprint in hosts[host].lower():
            print(f"    [+] Service: Mail ({mail_fingerprint})")
    for http_fingerprint in HTTP_FINGERPRINTS:
        if http_fingerprint in hosts[host].lower():
            print(f"    [+] Service: HTTP ({http_fingerprint})")
    for db_fingerprint in DB_FINGERPRINTS:
        if db_fingerprint in hosts[host].lower():
            print(f"    [+] Service: Database ({db_fingerprint})")
    for remote_fingerprint in REMOTE_FINGERPRINTS:
        if remote_fingerprint in hosts[host].lower():
            print(f"    [+] Service: Remote ({remote_fingerprint})")
    else:
        if windows_fingerprint_count > linux_fingerprint_count:
            print(f"    [+] OS: Most likely Windows")
        elif linux_fingerprint_count > windows_fingerprint_count:
            print(f"    [+] OS: Most likely Linux")
        else:
            print(f"    [+] OS: Unknown")
