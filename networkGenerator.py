import json
import sys
import os

networkSize = int(sys.argv[1])

template = {}

# Information for the genesis
template['Genesis'] = {}
# Information for the network
template['Genesis']["NetworkName"] = str(networkSize) + "nodes-net"
template['Nodes'] = []
template['Genesis']["Wallets"] = []

equalStake=round((100.0/networkSize),2)

remainder=round((100.0 - (equalStake * networkSize)),2)

print(str(networkSize-1) + " nodes have " + str(equalStake))
print("1 node has " + str(equalStake - remainder))

for i in range(0,networkSize):
    # name of the wallet
    walletName="Wallet"+str(i+1)
    template['Nodes'].append({
        "Name": "Node-" + str(i+1),
            "Wallets": [
                {
                    "Name": "Wallet"+ str(i+1),
                    "ParticipationOnly": bool(0)
                }
            ]
    })
    # One wallet has more stake than others
    if i == 0 :
        template['Genesis']["Wallets"].append({
            "Name": walletName,
            "Stake": equalStake + remainder,
            "Online": bool(1)
        })
    else:
        template['Genesis']["Wallets"].append({
                "Name": walletName,
                "Stake": equalStake,
                "Online": bool(1)
            })

# add relay node
template['Nodes'].append({
    "Name": "Relay-Node",
    "IsRelay": bool(1)
})



file = os.path.join('network_templates', str(networkSize) + '-nodes.json')
stream = open(file, 'w')
json.dump(template, stream)