# PathFinder - helps to visualize the test path, this is a path finder for the workflows.

E1:E:Start here:S1: :
S1:S:This is a switch it moves to multiple things:Path 1:Path 2:Path 3:Path 4:
G1:G:SWITCH_NAME:S00:C01:PASS:X

S00:S:Again making switch:Path 5:Path 6:
G00:G:SWITCH_2:C01:X

C01:C:Case Node has two nodes:PASS:X:

PASS:P:Positive:X::

X:X:Exit Node: : :
