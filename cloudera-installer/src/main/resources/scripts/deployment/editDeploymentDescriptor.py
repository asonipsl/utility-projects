#!/usr/bin/python
import json,sys
import os
import subprocess
from pprint import pprint

descriptor_file_path = sys.argv[1]

with open(descriptor_file_path) as data_file:    
    descriptorJSON = json.load(data_file)

## if file exists, delete it ##
if os.path.isfile("deploy_desc.json"):
    os.remove("deploy_desc.json")

count=0
for service in descriptorJSON["clusters"][0]["services"]:
    serviceName=service["name"]
    if serviceName == "hdfs1":
        p = subprocess.Popen("sh getRoles.sh HDFS", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for roleFile in p.stdout.readlines():
            fileName = roleFile.rstrip()
            with open(fileName) as data_file:
                hdfsRoleJSON = json.load(data_file)
            descriptorJSON["clusters"][0]["services"][count]["roles"].append(hdfsRoleJSON)
    elif serviceName == "hbase1":
        p = subprocess.Popen("sh getRoles.sh HBASE", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for roleFile in p.stdout.readlines():
            fileName = roleFile.rstrip()
            with open(fileName) as data_file:
                hbaseRoleJSON = json.load(data_file)
            descriptorJSON["clusters"][0]["services"][count]["roles"].append(hbaseRoleJSON)
    elif serviceName == "hive1":
        p = subprocess.Popen("sh getRoles.sh HIVE", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for roleFile in p.stdout.readlines():
            fileName = roleFile.rstrip()
            with open(fileName) as data_file:
                hiveRoleJSON = json.load(data_file)
            descriptorJSON["clusters"][0]["services"][count]["roles"].append(hiveRoleJSON)
    elif serviceName == "oozie1":
        p = subprocess.Popen("sh getRoles.sh OOZIE", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for roleFile in p.stdout.readlines():
            fileName = roleFile.rstrip()
            with open(fileName) as data_file:
                oozieRoleJSON = json.load(data_file)
            descriptorJSON["clusters"][0]["services"][count]["roles"].append(oozieRoleJSON)
    elif serviceName == "zookeeper1":
        p = subprocess.Popen("sh getRoles.sh ZOOKEEPER", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for roleFile in p.stdout.readlines():
            fileName = roleFile.rstrip()
            with open(fileName) as data_file:
                zookeeperRoleJSON = json.load(data_file)
            descriptorJSON["clusters"][0]["services"][count]["roles"].append(zookeeperRoleJSON)
    elif serviceName == "mapreduce1":
        p = subprocess.Popen("sh getRoles.sh MAPREDUCE", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        for roleFile in p.stdout.readlines():
            fileName = roleFile.rstrip()
            with open(fileName) as data_file:
                mapreduceRoleJSON = json.load(data_file)
            descriptorJSON["clusters"][0]["services"][count]["roles"].append(mapreduceRoleJSON)

    count=count+1

# Appending hosts info
p = subprocess.Popen("sh getRoles.sh HOST", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for roleFile in p.stdout.readlines():
    fileName = roleFile.rstrip()
    with open(fileName) as data_file:
        hostInfoJSON = json.load(data_file)
    descriptorJSON["hosts"].append(hostInfoJSON)

# Appending monitor services
p = subprocess.Popen("sh getRoles.sh MONITOR_SERVICE", shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
for roleFile in p.stdout.readlines():
    fileName = roleFile.rstrip()
    with open(fileName) as data_file:
        monitorServiceRoleJSON = json.load(data_file)
    descriptorJSON["managementService"]["roles"].append(monitorServiceRoleJSON)

text_file = open("deploy_desc.json", "w")
text_file.write(json.dumps(descriptorJSON, indent=4))
text_file.close()

# Finish
