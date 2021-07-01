#!/bin/bash

sizeNetwork=$1
destination=$2
for i in `seq 1 $sizeNetwork`; do
    nodeFolder=$destination/Node-$i
    # taken from https://github.com/reach-sh/reach-lang/blob/a3a7c874609b1878a4f5164f462cf32910376ae3/scripts/algorand-devnet/generate_algorand_network.sh
    # Get the wallet address
    walletAddr=$(goal account list -d $nodeFolder | awk '{print $2}')
    echo ""
    echo " Wallet: $walletAddr, Node: $nodeFolder"
    echo " Getting $walletAddr's key..."
    # Get the mnemonic key
    key=$(goal account export -a $walletAddr -d $nodeFolder | cut -f 6- -d ' '  | xargs echo)
    echo " Mnemonic key: $key"
    echo "Done! ✅ "
    echo ""
    echo "$key" >> $nodeFolder/mnemonic.key
done