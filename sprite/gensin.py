import sys
import math

def gensin(freq, amp, offset):
    for i in range(0, freq):
        norm = float(i)/freq
        val = (math.sin(norm * math.pi * 2.0) * amp) + offset
        print "!byte $%02x" % int(val)

if __name__=="__main__":
    gensin(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))
