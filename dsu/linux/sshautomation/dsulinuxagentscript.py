import os
import yaml
from wrapper import *
from datetime import datetime
import utils.iptables as iptables
from utils.passgen import genPassword
from getpass import getpass
import hashlib
import time
boxes = {}
config_path = 'config.yml'
# passwordFunc = lambda x: 'default'
seed="TotallySecureSeed1"
rounds=1000
auxiliary = None

with open(config_path, 'r') as file:
        data = yaml.safe_load(file)
def mkdir(path):
  try: return os.mkdir(path)
  except FileExistsError: return None

def Root_Password_Changes(box):
    mkdir(f"boxdata/{box}")
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password = genPassword(seed + box + "root",rounds)
        root_password = default_password
    else:
        default_password = data["global"]["default_password"]
        root_password = genPassword(seed + box + "root",rounds)

    command = f'root:{root_password}\n'
    if(run_ssh_command(box,default_password,"chpasswd",stdinText=command) != -1):
        open(f"boxdata/{box}/changedpassword", "w").close()

def User_Password_Changes(box):
    mkdir(f"boxdata/{box}")
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    users = [i.split(":")[0] for i in run_ssh_command(box,default_password,"cat /etc/passwd", False).split("\n")]
    users.remove("root")
    users.remove("")
    mkpasswd = '\n'.join(f"{i}:{genPassword(seed+box[0] + i,rounds)}" for i in users)
    run_ssh_command(box,default_password ,"chpasswd",stdinText=mkpasswd)


def files_to_backup(box):
    mkdir(f"boxdata/{box}")
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    files_to_backup_entry = data.get('files_to_backup', [])
    for file in files_to_backup_entry:
        command = f'cp {file} /root/{file}'
        run_ssh_command(box,default_password,command)


def firewall_stuff(box):
     if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
     else:
        default_password =data["global"]["default_password"]
     mkdir(f"boxdata/{box}")
     command = "ss -naH4"
     stdout = run_ssh_command(box,default_password,command,False)
     iptables.UNRESTRICTED_SUBNETS = [data['global']['unrestricted_subnet']]
     bashscript = iptables.genFirewall(stdout)
     with open(f'boxdata/{box}/firewall.sh', 'w') as file:
            file.write(bashscript)
     print(bashscript)


def audit_Users(box):
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    users = [i.split(":")[0] for i in run_ssh_command( box,default_password,"cat /etc/passwd", False).split("\n")]
    mkdir(f"boxdata/{box}")
    with open(f'boxdata/{box}/users.txt', 'w') as file:
        for user in users:
            file.write(user+"\n")



def change_SSH_Settings(box):
    insert = [
        "PermitRootLogin yes",
        "PubkeyAuthentication no",
        "UseDNS no",
        "PermitEmptyPasswords no",
        "AddressFamily inet"
    ]
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    sshd_config = '\n'.join(insert) + '\n' + run_ssh_command(box,default_password,"cat /etc/ssh/sshd_config",False)
    run_ssh_command(box,default_password,"cat > /etc/ssh/sshd_config",stdinText=sshd_config)


def modify_php_settings(box):
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    php_settings = '\n'.join(f'{setting} = {value}' for setting, value in data.get('php_settings',{}).items()) + '\n'
    php_ini_list = run_ssh_command(box, default_password, "find / -name 'php.ini' 2> /dev/null", print_output=False).split('\n')[:-1]
    for php_ini in php_ini_list:
        php_ini_content  = run_ssh_command(box,default_password,f"cat '{php_ini}'")
        php_ini_content += php_settings
        run_ssh_command(box, default_password, f"cat > '{php_ini}'", stdinText= php_ini_content)

def change_sysctl_settings(box):
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    sysctl_conf  = '\n'.join(f'{setting} = {value}' for setting, value in data.get('sysctl_settings',{}).items()) + '\n'
    sysctl_conf += run_ssh_command(box,default_password,"cat /etc/sysctl.conf",False)
    run_ssh_command(box,default_password,"cat > /etc/sysctl.conf", stdinText=sysctl_conf)



def run_single_command(box):
    mkdir(f"boxdata/{box}")
    global auxiliary
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    if auxiliary == None: auxiliary = input("cmd: ")
    writetofile = run_ssh_command(box, default_password, auxiliary,False)
    with open(f"boxdata/{box}/singlecommandoutput.txt","a") as output:
        output.write(f"[{timestamp}] Box: {box}\n")
        output.write(f"Command: {auxiliary}\n")
        output.write(writetofile)
    print(writetofile)

def execute_BashScript(box):
    mkdir(f"boxdata/{box}")
    global auxiliary
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    try:
        if auxiliary == None: auxiliary = input("Script Path: ")
        with open(auxiliary, 'r') as bash_script:
            script_content = bash_script.read()
        if "$BASH_SOURCE" in script_content:
            remoteName = hashlib.md5(script_content.encode()).hexdigest() + '.sh'
            writetofile = run_ssh_command(box, default_password, f'cat > /tmp/{remoteName} && bash /tmp/{remoteName} && rm -v /tmp/{remoteName}',False,stdinText=script_content)
        else:
            writetofile = run_ssh_command(box, default_password, f'bash',False,stdinText=script_content)
        with open(f"boxdata/{box}/bashscriptoutput.txt","a") as output:
            output.write(f"[{timestamp}] Box: {box}\n")
            output.write(f"Command: {auxiliary}\n")
            output.write(writetofile)
        print(writetofile)

    except Exception as e:
        print(f"Error: {e}")

def Remove_All_Admin_Users(box):
    mkdir(f"boxdata/{box}")
    if(os.path.isfile(f'boxdata/{box}/changedpassword')):
        default_password  = genPassword(seed + box + "root",rounds)
    else:
        default_password =data["global"]["default_password"]
    command='''for group in sudo admin; do for user in $(getent group $group | cut -d: -f4 | tr ',' ' '); do [[ $user != "root" ]] && sudo deluser $user $group; done; done'''
    run_ssh_command(box,default_password,command)

def enumerate(box):
    #WIP
    print("enum")

def fix_pam(box):
    #WIP
    print("pam")



functions = [audit_Users,Root_Password_Changes,User_Password_Changes,files_to_backup,firewall_stuff,execute_BashScript,change_SSH_Settings,modify_php_settings,change_sysctl_settings,run_single_command,Remove_All_Admin_Users]
def exec_function(function_number):
     global auxiliary
     auxiliary = None
     for line in open("boxes.conf"):
        if "#" not in line:
            ip_address = line.strip()
            # root_password = passwordFunc(ip_address + "root")
            # boxes[ip_address]=(root_password)
            functions[function_number](ip_address)



def main():
    global seed
    seed = getpass("seed: ")
    # if input("Use seed? ") == 'y':
    #         passwordFunc = lambda x: genPassword(x,rounds)
    # else:
            
    #         passwordFunc = lambda x: data['global']['default_password']
    while(True):
        print("\nSelect an option:")
        print("1. Audit Users")
        print("2. Root Password Changes")
        print("3. User Password Changes")
        print("4. Files Backup")
        print("5. Firewall Stuff")
        print("6. Execute Bash Script")
        print("7. Change SSH Settings")
        print("8. Modify PHP Settings")
        print("9. Change Sysctl Settings")
        print("10. Run Single Command")
        print("11. Remove all Admin Users")
        print("0. Exit")
        option = input("Enter the option number: ")
        if(int(option) > 0 and int(option) <= 11):
            exec_function(int(option)-1)
        elif(int(option)==0):
            break
main()
