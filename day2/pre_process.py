# read in a file, add 'data([' to the beginning of each line and '])' to the end of each line
# replace each space with a ',' and write out put to '[filename].pl'

import sys

def pre_process(file_name):
    with open(file_name, 'r') as f:
        lines = f.readlines()
    with open(file_name + '.pl', 'w') as f:
        for line in lines:
            f.write('data([' + line.replace(' ', ',').replace('\n', '') + ']).\n')

if __name__ == '__main__':
    pre_process(sys.argv[1])
