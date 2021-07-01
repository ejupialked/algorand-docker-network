#!/bin/bash

netFolder=$2
nParticipants=$3


bold=$(tput bold)
normal=$(tput sgr0)

# api token for algod and kmd service (used by the evaluator)
apiToken="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

# Algod relay
algodRelayDocker='{
    "Version": 14, 
    "GossipFanout": 2, 
    "NetAddress": ":4444",
    "EndpointAddress": "0.0.0.0:4001",
    "DNSBootstrapID": "",
    "EnableProfiler": true
}'

# Algod participant
algodPartDocker='{
	"Version": 14,
	"GossipFanout": 2,
	"IncomingConnectionsLimit": 0,
	"DNSBootstrapID": "",
	"EndpointAddress": "0.0.0.0:4001",
	"EnableProfiler": true
}'

# kmd relay
kmdDocker='{
    "address": "0.0.0.0:4002", `
    "allowed_origins": [
        "*"
    ]
}'

function configureDocker {
    echo '>> 🚢 Configuring network for docker-compose...'
    cd $netFolder
    echo ">> 🧹 Cleaning this net: ${PWD}"
    echo ""
    sleep 1
    configurePartDocker
    configureRelayDocker
    createDockerCompose
}

function configurePartDocker {
    echo "🛳 Configuring participants nodes for docker-compose..."

    # generate all algod/kmd configs for all nodes
    for i in `seq 1 $nParticipants`;
    do
        nodeFolder="Node-${i}"
        cd $nodeFolder

        # create algod token 
        touch algod.token
        echo $apiToken >> algod.token  

        touch config.json
        echo $algodPartDocker >> config.json
        echo ">>✅ Created algod config for ${bold}${nodeFolder}${normal} in: ${PWD}..."

        # check if folder exists
        if [ ! -d "kmd-v0.5" ]; then
            mkdir kmd-v0.5
        fi

        cd kmd-v0.5
        
        # create kmd token 
        touch kmd.token
        echo $apiToken >> kmd.token

        touch kmd_config.json
        echo $kmdDocker >> kmd_config.json
        echo ">>✅ Created kmd config for ${bold}${nodeFolder}${normal} in: ${PWD}..."

        cd ..

        cp ../../docker_config/part/start.sh start.sh

        cd ..

        echo " "
    done
}

function configureRelayDocker {
    echo ">>🛳 Configuring relay node for docker-compose..."
    cd 'Relay-Node'
    
    # create algod token 
    touch algod.token
    echo $apiToken >> algod.token

    touch config.json
    echo $algodRelayDocker >> config.json
    echo ">>✅ Created algod config for ${bold}Relay-Node${normal} in: ${PWD}..."


    if [ ! -d "kmd-v0.5" ]; then
        mkdir kmd-v0.5
    fi

    cd kmd-v0.5

    # create kmd token
    touch kmd.token
    echo $apiToken >> kmd.token

    touch kmd_config.json
    echo $kmdDocker >> kmd_config.json
    echo ">>✅ Created kmd config for ${bold}Relay-Node${normal} in: ${PWD}..."

    cd ..

    cp ../../docker_config/relay/start.sh start.sh
    
}

function createDockerCompose {
    cd ../..
    echo ">> Creating docker-compose.yml file..."
    python3 dockerYamlGenerator.py $nParticipants $netFolder   
    echo ">> Done!"
}

function clean {
    echo ">>🧹 Cleaning configuration files..."
    cd $netFolder
    echo ">>🧹 Cleaning this net: ${PWD}"
    sleep 1
    echo ""

    rm -rf nodes.json

    for i in `seq 1 $nParticipants`;
    do
        nodeFolder="Node-${i}"

        # check if node exists
        if [[ -d $nodeFolder ]]; then
            cd $nodeFolder
            echo ">>🗑 Removing algod config for ${bold}${nodeFolder}${normal} in: ${PWD}..."
            rm -rf config.json
            echo ">>🗑 Removing algod.token for ${bold}${nodeFolder}${normal} in:  ${PWD}..."        
            rm -rf algod.token

            if [ -d "kmd-v0.5" ]; then
                cd 'kmd-v0.5'
                echo ">>🗑 Removing kmd.token for ${bold}${nodeFolder}${normal} in:  ${PWD}..."        
                rm -rf kmd.token

                
                if [[ -f "kmd_config.json" ]]; then
                    echo ">>🗑 Removing kmd config for ${bold}${nodeFolder}${normal} in:  ${PWD}..."        
                    rm -rf kmd_config.json
                fi
                cd ..
            fi
            
            cd ..
        fi
        echo ""
    done
    
    if [[ -d "Relay-Node" ]]; then
        cd 'Relay-Node'
        echo ">>🗑 Removing algod config for ${bold}Relay-Node${normal} in: ${PWD}..."
        rm -rf config.json
        rm -rf algod.token

        if [ -d "kmd-v0.5" ]; then
            cd 'kmd-v0.5'
            echo ">>🗑 Removing kmd.token for ${bold}${nodeFolder}${normal} in:  ${PWD}..."        
            rm -rf kmd.token
            if [[ -f "kmd_config.json" ]]; then
                echo ">>🗑 Removing kmd config for ${bold}Relay-Node${normal} in: ${PWD}..."        
                rm -rf kmd_config.json
            fi
            
            cd ..
        fi
    fi
}

if [[ $1 = "docker" ]]; then
    configureDocker
    exit
fi

if [[ $1 = "clean" ]]; then
    clean
    exit
fi

# sh configureNetwork.sh clean testNet 3