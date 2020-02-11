#!/usr/bin/env bash

# PROCESS ARGS
if [ "$#" -lt 3 ]; then
    echo 'Missing required arguments, exiting.'
    exit
fi
if [ "$#" -gt 4 ]; then
    echo 'Too many arguments, exiting.'
    exit
fi

# CHECK IF COMMAND OR SCRIPTFILE
if [ -f "$3" ]; then
    script="$3"
else
    command="$3"
fi

# SHOW INPUTS
echo -e "User:\t\t$1"
echo -e "Addresses:\t$2"
if [ -z "$command" ]; then
    echo -e "Script:\t\t$3"
    script_file=$(mktemp)
    cp $3 ${script_file}
    echo -e "\necho 'done' && exit" >> ${script_file}
    cat ${script_file}
else
    echo -e "Command:\t$3"
fi
if [ -z "$4" ]; then
    echo -e "Output:\t\tstdout"
else
    echo -e "Output:\t\t$4"
fi

# CHECK HOSTS
temp_scan=$(mktemp)
temp_hosts=$(mktemp)
nmap $2 -p22 -Pn -oG ${temp_scan} -q >/dev/null 2>&1
cat ${temp_scan}
awk '{print $2}' ${temp_scan} | uniq | head -n-1 | tail -n+2 > ${temp_hosts}
mapfile -t hosts < ${temp_hosts}
rm ${temp_scan} ${temp_hosts}
num_hosts=${#hosts[@]}
echo -e "Number:\t\t$num_hosts"

# STOP IF NONE FOUND
if [ "$num_hosts" -eq 0 ]; then
    echo 'Nothing to do, exiting.'
    exit
fi

# START THE ( COMMAND | SCRIPTFILE )
temp_files=()
started=0
for host in ${hosts[@]}; do
    temp_files+=($(mktemp))

    if [ -z "$command" ]; then
        # send the script
        nohup ssh -T -o "StrictHostKeyChecking=no" -o "ConnectTimeout=2" \
            $1@$host < ${script_file} > \
            ${temp_files[$started]} 2>/dev/null &
    else
        # send the command
        nohup ssh -o "StrictHostKeyChecking=no" -o "ConnectTimeout=2" \
            $1@$host "$3 && echo 'done' && exit" > \
            ${temp_files[$started]} 2>/dev/null &
    fi

    ((started=started+1))
    echo -ne "\rStarted:\t$started/$num_hosts"
    sleep 0.1 # visible for user and nice to network

done; echo

# WAIT FOR THE TASKS TO COMPLETE
count=0
spinner="|/-\\"
spin=0
while [ $count -lt $num_hosts ]; do
    count=0
    for file in ${temp_files[@]}; do
        if [[ $(tail -n 1 $file) = "done" ]]; then
            ((count=count+1))
        fi
    done
    echo -ne "\rDone:\t\t$count/$num_hosts "
    echo -ne "${spinner:$spin%4:1}"
    ((spin=spin+1)) # TODO move mod to here!
    sleep 0.1 # visible for user and nice to network
done; echo -e "\rDone:\t\t$count/$num_hosts  ";

# OUTPUT
echo -e 'Output:\n'
for file in ${temp_files[@]}; do
    cat $file | head -n-1
done

# CLEAN UP TEMP FILES
for file in ${temp_files[@]}; do
    rm $file
done

# DONE
echo -e '\nDone!'
exit