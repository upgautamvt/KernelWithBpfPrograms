#!/usr/bin/env sh

if [ $# -ne 2 ] 
then
    echo """
Usage:
    ./get_helper_addresses.sh [PATH_TO_BPF.H] [OUTFILE]

Uses gperf to create a perfect hash function to map BPF helper functions to their
canonical ID. Uses the system bpf.h file to find helper function names.

Generates two files:
    outfile.txt       - contains all the helper function names and their id's
    outfile-name.c   - contains a perfect hash function and lookup using gperf
    outfile-id.c   - contains a function to go from helper id to name  

         """
    exit 1
fi

# Reads in the bpf.h file and stores the result to HELPERS
# Each helper function definition follows a particular pattern so we can use
# sed to extract the function name from the definition
HELPERS=$(cat $1 | sed -ne 's/\tFN(\([a-z0-9_]*\).*/bpf_\1/p')

# Emit header information for gperf
echo "struct helper { char* function; int id; };" > $2.gperf
echo "%define lookup_function_name get_helper_id" >> $2.gperf
echo "%define slot_name function" >> $2.gperf
echo "%includes" >> $2.gperf

echo "%%" >> $2.gperf

i=0

#echo -n "const char *helper_arr[] = {" > $2-id.c
for h in $HELPERS; do
    echo "$h, $i" >> $2.gperf
    echo "$h, $i" >> $2.txt
#    echo -n "\"$h\", " >> $2-id.c
    i=$((i+1))
done


echo "%%" >> $2.gperf
echo "struct helper * get_helper_id(register const char *str, register size_t len);" >> $2.gperf
echo -n "const char *helper_arr[] = {" >> $2.gperf
for h in $HELPERS; do
    echo -n "\"$h\", " >> $2.gperf
done
echo "};" >> $2.gperf
echo "int helper_to_id(char* str) { return get_helper_id(str, strlen(str))->id; };" >> $2.gperf
echo "const char * id_to_helper(int id) { return helper_arr[id]; };" >> $2.gperf

# Runs gperf 100 times to be more space efficient
gperf -m 100 -t $2.gperf > $2.c


echo "struct helper {char* function; int id;};\nchar* id_to_helper(int id);\nint helper_to_id (const char* str);\nstruct helper * get_helper_id(register const char *str, register size_t len);" > $2.h
