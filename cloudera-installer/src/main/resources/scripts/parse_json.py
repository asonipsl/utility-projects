#!/usr/bin/python
import json,sys
from pprint import pprint

str=sys.argv[1]
#print str
jsonObj = json.loads(sys.argv[1])
if sys.argv[2] in jsonObj:
    print jsonObj[sys.argv[2]]
elif "state" in jsonObj and sys.argv[2] in jsonObj["state"]:
   print jsonObj["state"][sys.argv[2]]
elif "items" in jsonObj and sys.argv[2] in jsonObj["items"][0]:
    print jsonObj["items"][0][sys.argv[2]]
