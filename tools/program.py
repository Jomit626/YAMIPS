import sys
import getopt
from serial import Serial,EIGHTBITS,PARITY_NONE,STOPBITS_ONE
from elftools.elf.elffile import ELFFile

help_info = 'test.py -c <COMx|/dev/ttySx> -f <file>'

COMMAND_PROGRAM=0xf0f0f0f0
COMMAND_JRL=0x0f0f0f0f
COMMAND_ECHO=0x12345678
# python tools/program.py -f tests/example/example.out -c COM4
target_section_names = ['.text', '.data']

num_to_bytearray = lambda x : bytearray([(x >> 24) & 0xff,
                                         (x >> 16) & 0xff,
                                         (x >> 8) & 0xff,
                                         (x >> 0) & 0xff,
                                        ])
bytes_to_num = lambda x : ((x[0] << 24) & 0xff000000 ) | \
                          ((x[1] << 16) & 0x00ff0000 )| \
                          ((x[2] << 8)  & 0x0000ff00 )| \
                          ((x[3] << 0)  & 0x000000ff )
def main():
    serial_com = ''
    filename = ''
    test = 0
    echo = 0
    try:
        opts, _ = getopt.getopt(sys.argv[1:],"hec:f:",["com=","file="])
    except getopt.GetoptError:
        print (help_info)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print (help_info)
            sys.exit()
        elif opt in ("-c", "--com"):
            serial_com = arg
        elif opt in ("-f", "--file"):
            filename = arg
        elif opt == '-e':
            echo = 1
    
    if len(serial_com) == 0:
        test = 1

    if not test:
        print ('COM:',serial_com)
        com = Serial( port=serial_com,
                    baudrate=9600,
                    bytesize=EIGHTBITS,
                    parity=PARITY_NONE,
                    stopbits=STOPBITS_ONE ) 
        if echo:
            write_to_serial(com, COMMAND_ECHO, 0)
            exit(0)
    else:
        print ('- Test Mode -')
    
        
    print ('ELF file:',filename)
    enter_addr , section_data = process_file(filename)

    print ('')
    for name, addr, data in section_data:
        print ('Section:',name)
        print ('Baseaddr:',hex(addr))
        print ('Datasize:',len(data)//4)
        if not test:
            write_to_serial(com, COMMAND_PROGRAM, addr, data)
            n = read_word_from_serial(com)
            print ('Recived:',n)
            if n != len(data)//4:
                print ('Error!')
        else:
            test_print(COMMAND_PROGRAM, addr, data)
    

    print ('JAL to address', hex(enter_addr))
    if not test:
        write_to_serial(com, COMMAND_JRL, enter_addr)
        n = read_word_from_serial(com)
        print ('JAL to address', hex(n))
    else:
        test_print(COMMAND_JRL, enter_addr)
def process_file(filename):
    result = []
    with open(filename, 'rb') as f:
        elffile = ELFFile(f)
        for name in target_section_names:
            section = elffile.get_section_by_name(name)
            if section is None:
                print ('Section %s no found, ignored.' % name)
            else:
                result.append((
                    name,
                    section.header["sh_addr"],
                    bytearray(section.data()),
                ))
    return (elffile['e_entry'], result)

def write_to_serial(com, cmd, addr, data=None):
    if data is None:
        data = bytearray()
    else:
        data = num_to_bytearray(len(data)//4) + data
    
    send_data = num_to_bytearray(cmd) + num_to_bytearray(addr) + data
    #print(send_data)
    com.write(send_data)

def test_print(cmd, addr, data=None):
    if data is None:
        data = bytearray()
    
    n = len(data)//4
    for i in range(n):
        print( "ins[%d] =0X%x;" % (i, bytes_to_num(data[i*4:i*4 + 4])))

def read_word_from_serial(com):
    data = com.read(4)
    recived =  ((data[0] << 24) & 0xff000000 ) | \
                ((data[1] << 16) & 0x00ff0000 )| \
                ((data[2] << 8)  & 0x0000ff00 )| \
                ((data[3] << 0)  & 0x000000ff )
    return recived

if __name__ == "__main__":
    main()