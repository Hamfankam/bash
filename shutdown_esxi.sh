#!/bin/bash
server="ip_servers"
login=root
pathkey=.ssh/esxi_id_rsa
output=$(sudo ssh -i $pathkey $login@$server "halt")
