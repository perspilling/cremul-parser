#!/bin/bash

# Converts files presumed to be in ISO-8859-1 (Latin) encoding to UTF-8. The
# converted files will be given a -utf-8.txt extension

for i in $*
do
    echo converting $i
    cat $i | iconv -f ISO-8859-1 -t UTF-8 > ${i%%.*}-utf-8.txt
done