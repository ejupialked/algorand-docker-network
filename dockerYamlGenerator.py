import yaml
import sys
import os

networkSize = int(sys.argv[1])
networkPath = sys.argv[2]

algodPort=4001
kmdPort=4002

yaml_file={}
yaml_file['version']="3"


nodes = {}

################# Relay node #################

relayNode={}
# # env variable required by goal and kmd
# environment=[]
# environment.append('ALGORAND_DATA'+ ':' + "/root/data")
# relayNode['environment']=environment


relayNode['image']='algorand/stable:2.4.1'

# keep container running
relayNode['tty']='true'

# image name
relayNode['image']='algorand/stable:2.4.1'

# command to execute when container has started
relayNode['command']='bash -c "/root/node/goal node start -d /root/data && /root/node/carpenter -file /root/data/node.log"'

# hostname of the relay node
relayNode['hostname']='Relay-Node'

# map local host ports to docker container
ports=[]
# relayNode has the same port for the host and container
ports.append(str(algodPort)+':'+str(algodPort))
relayNode['ports']=ports

# map relay node directory  to container
volumes=[]
volumes.append('./Relay-Node/:/root/data:rw')
relayNode['volumes']=volumes

nodes.update({ 'relay_node': relayNode })

###################################################

################# Creates participant nodes #################
for i in range(0,networkSize):
    node={}

    # network ports exposed
    containerAlgodPort=str(4002+i)
    containerKmdPort=str(5002+i)

    # name of the node
    node['hostname']='Node-'+str(i+1)

    # keep running container after execution
    node['tty']='true'

    # image name
    node['image']='algorand/stable:2.4.1'

    # command to execute when container has started
    node['command']='bash -c "/root/node/goal node start -p "Relay-Node:4444" -d /root/data && /root/node/carpenter -file /root/data/node.log"'

    # map local host ports to docker container
    ports=[]
    ports.append(str(containerAlgodPort)+':'+str(algodPort))
    ports.append(str(containerKmdPort)+':'+str(kmdPort))

    # map participant node directory from volume to container
    volumes=[]
    volumes.append('./Node-'+ str(i+1) + '/:/root/data:rw')

    # Start partipants nodes only after relay node has started
    depends_on=[]
    depends_on.append('relay_node')
    node['depends_on']=depends_on

    # add volumes
    node['volumes']=volumes

    # add ports
    node['ports']=ports

    # Add node container service
    nodes.update({ 'node_'+str(i+1) : node })
#############################################################


yaml_file['services'] = nodes
file = os.path.join(networkPath, "docker-compose.yml")
stream = open(file, 'w')
yaml.dump(yaml_file, stream)