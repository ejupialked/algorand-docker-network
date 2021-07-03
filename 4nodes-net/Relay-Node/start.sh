#!/bin/bash
echo "Removing old node.log file..."
rm -f /root/data/node.log

echo "Starting algod as a relay, with this config:"
cat /root/data/config.json
/root/node/goal node start
/root/node/carpenter -file /root/data/node.log
