BEGIN {
    printf "memory_initialization_radix = 16;\nmemory_initialization_vector =\n";
    pre_addr = null;
} 

$2 ~ "[0-9a-f]{8}" {

    addr = strtonum("0x"$1);;
    instruction = $2;

    if(pre_addr == null)
        pre_addr = addr;
    
    offset = addr - pre_addr
    for(;offset > 4; offset -= 4)
        print "00000000,";
    print instruction",";

    pre_addr = addr;
} 

END {
print "00000000;";
}