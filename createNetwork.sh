#!/bin/bash

# an integer defining the size of the network
sizeNetwork=$1

echo ">> 📃 Creating template with size: ${sizeNetwork}"
python networkGenerator.py $sizeNetwork
echo " Done! ✅ "
echo " "

# The goal network template
template="network_templates/$sizeNetwork-nodes.json"

echo ">> 📃 Template selected: ${template}"
echo ">> #️⃣ Size network selected: ${sizeNetwork}"
echo ""
echo ">> 🌐 Creating network in 2 seconds, CTRL+C to stop..."
sleep 2

destination="${sizeNetwork}nodes-net"

if [ -d "$destination" ]; then
    echo ">> ⚠️  ${destination} already exists. Deleting it.. 🗑 "
    rm -rf $destination
    echo ""
fi

sleep 2

goal network create -r $destination -n $destination -t $template


echo " Configuring ${destination} network for ${deployDestination} ... "
echo ">> ⏳ Configuring network in 2 seconds, CMD+C to stop.."
echo ""
sleep 2

echo " 🧹 Cleaning any pre-configuration..."
sh configureNetwork.sh clean $destination $sizeNetwork   
echo " Done! ✅ "
echo ""
echo "################################"
echo ""

sleep 2

sh configureNetwork.sh "docker" $destination $sizeNetwork   

echo $sizeNetwork >> $destination/sizeNetwork

# echo " Getting mnemonic key of each wallet..."
# for i in `seq 1 $sizeNetwork`; do
#     nodeFolder=$destination/Node-$i
#     # taken from https://github.com/reach-sh/reach-lang/blob/a3a7c874609b1878a4f5164f462cf32910376ae3/scripts/algorand-devnet/generate_algorand_network.sh
#     # Get the wallet address
#     walletAddr=$(goal account list -d $nodeFolder | awk '{print $2}')
#     echo ""
#     echo " Wallet: $walletAddr, Node: $nodeFolder"
#     echo " Getting $walletAddr's key..."
#     # Get the mnemonic key
#     key=$(goal account export -a $walletAddr -d $nodeFolder | cut -f 6- -d ' '  | xargs echo)
#     echo " Mnemonic key: $key"
#     echo "Done! ✅ "
#     echo ""
#     echo "$key" >> $nodeFolder/mnemonic.key

# done