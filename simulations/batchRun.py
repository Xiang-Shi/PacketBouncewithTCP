#!/Library/Frameworks/Python.framework/Versions/2.7/bin/python

import os

os.chdir('/Users/shixiang/Documents/omnetpp-4.6/samples/PacketBouncewithTCP/src') 
os.system('make MODE=debug CONFIGNAME=gcc-debug all') 
os.chdir('/Users/shixiang/Documents/omnetpp-4.6/samples/PacketBouncewithTCP/simulations')
os.system('../src/PacketBouncewithTCP -r 0 -u Cmdenv -n ../src:.:../../inet/examples:../../inet/src:../../inet/tutorials -l ../../inet/src/INET omnetpp.ini')
os.chdir('/Users/shixiang/Documents/omnetpp-4.6/samples/PacketBouncewithTCP/simulations/results')
os.system('scavetool vector -p \'module(PacketBouncewithTCP.client.tcp) AND ("SHI: reordering density")\' -O outsplit.csv -F splitcsv General-0.vec')
