#!/bin/bash

<<'EOF'
   This script ensures that each UE simulation runs in its own
   isolated network environment, preventing conflicts between them.
   It can create, delete, list, and open shells in namespaces.
   Usage:
        To Create a Network Namespace with the given UE ID:
            ./multi-ue.sh -c <num>
        To Delete a Network Namespace with the given UE ID:
            ./multi-ue.sh -d <num>
        To List all network namespaces:
            ./multi-ue.sh -l
        To Open a shell in a specific namespace or to open in the last processed namespace:
            ./multi-ue.sh -o <num> or ./multi-ue.sh -e
EOF

ue_id=-1 # This variable keeps track of the last processed UE ID

# This function creates a network namespace and
# a pair of virtual ethernet interfaces
create_namespace() {

  # Set the UE ID to the first argument passed to the function
  ue_id=$1

  # Set the namespace name based on the UE ID
  local name="ue$ue_id"

  echo "creating namespace for UE ID ${ue_id} name ${name}"

  # Add a new network namespace with the name `ue$ue_id`
  ip netns add $name

  # Create a pair of virtual Ethernet devices, `v-eth$ue_id` and `v-ue$ue_id`
  ip link add v-eth$ue_id type veth peer name v-ue$ue_id

  # Move one end of the veth pair (`v-ue$ue_id`) into the newly created namespace
  ip link set v-ue$ue_id netns $name

  # Calculate a base IP address component based on the UE ID.
  BASE_IP=$((200+ue_id))

  # Assign an IP address to the veth interface outside the namespace.
  ip addr add 10.$BASE_IP.1.100/24 dev v-eth$ue_id

  # Set the veth interface outside the namespace up.
  ip link set v-eth$ue_id up

  # Add NAT and forwarding rules to allow network traffic to be masqueraded and forwarded properly.
  iptables -t nat -A POSTROUTING -s 10.$BASE_IP.1.0/255.255.255.0 -o lo -j MASQUERADE
  iptables -A FORWARD -i lo -o v-eth$ue_id -j ACCEPT
  iptables -A FORWARD -o lo -i v-eth$ue_id -j ACCEPT

  # Set the loopback interface up within the namespace.
  ip netns exec $name ip link set dev lo up

  # Assign an IP address to the veth interface inside the namespace.
  ip netns exec $name ip addr add 10.$BASE_IP.1.$ue_id/24 dev v-ue$ue_id

  # Set the veth interface inside the namespace up.
  ip netns exec $name ip link set v-ue$ue_id up
}

# This function deletes a network namespace and its associated veth interface.
delete_namespace() {

  # Set the UE ID to the first argument passed to the function
  local ue_id=$1

  # Set the namespace name based on the UE ID
  local name="ue$ue_id"

  echo "deleting namespace for UE ID ${ue_id} name ${name}"

  # Delete the veth interface outside the namespace.
  ip link delete v-eth$ue_id

  # Delete the network namespace.
  ip netns delete $name
}

# Lists all existing network namespaces.
list_namespaces() {
  # Lists the network namespaces.
  ip netns list
}

# Opens a shell within a specified or last processed network namespace.
open_namespace() {
  # Checks if `ue_id` is set to a valid value; if not, print an error message and exit
  if [[ $ue_id -lt 1 ]]; then
    echo "error: no last UE processed"
    exit 1
  fi

  # Set the namespace name based on the UE ID
  local name="ue$ue_id"

  echo "opening shell in namespace ${name}"
  echo "type 'ip netns exec $name bash' in additional terminals"

  # Executes a bash shell within the specified namespace.
  ip netns exec $name bash
}

# Display usage information for the script.
usage () {
  echo "$1"
  echo "$1 -c <num>: create namespace \"ue<num>\""
  echo "$1 -d <num>: delete namespace \"ue<num>\""
  echo "$1 -e: execute shell in last processed namespace"
  echo "$1 -l: list namespaces"
  echo "$1 -o <num>: open shell in namespace \"ue<num>\""
}

# Get the name of the script.
prog_name=$(basename $0)

# Check if the script is run as root; if not, print a message and exit
if [[ $(id -u) -ne 0 ]]; then
  echo "Please run as root"
  exit 1
fi

# Check if any parameters are passed to the script; if not, print an error message and usage information, then exits.
if [[ $# -eq 0 ]]; then
  echo "error: no parameters given"
  usage $prog_name
  exit 1
fi

# Parse the command-line options.
while getopts c:d:ehlo: cmd
do
  case "${cmd}" in
    c) create_namespace ${OPTARG};;
    d) delete_namespace ${OPTARG};;
    e) open_namespace; exit;;
    h) usage ${prog_name}; exit;;
    l) list_namespaces;;
    o) ue_id=${OPTARG}; open_namespace;;
    /?) echo "Invalid option"; usage ${prog_name}; exit;;
  esac
done
