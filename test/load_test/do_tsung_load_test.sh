#!/usr/bin/env bash

current_directory="$(dirname "$0")"

echo
echo "#####################################################"
echo "               Starting Tsung                        "
echo "#####################################################"
echo

# Duplicate tsung's output to STDOUT and bash variable
exec 5>&1
tsung_output=$(tsung -f "${current_directory}/basic_tsung_load_test.xml" start | tee >(cat - >&5))
#tsung_output="$(tee < /tmp/test_input.txt  >(cat - >&5))"

while read -r line
do
	directory_regexp='^Log directory is: (.+)$'
	if [[ ${line} =~ ${directory_regexp} ]]
	then
		tsung_log_dir=${BASH_REMATCH[1]}
	fi
done <<<"$tsung_output"

if [[ -z "${tsung_log_dir}" ]]
then
		echo "Pattern matching failed on tsung's output!"
		exit -1
fi

echo
echo "#####################################################"
echo "        Tsung is finished successfully               "
echo "#####################################################"
echo
echo "Process Tsung's result from the following directory: '${tsung_log_dir}'"

mkdir tsung_results 
pushd tsung_results > /dev/null
/usr/lib64/tsung/bin/tsung_stats.pl --stats "${tsung_log_dir}/tsung.log"
popd  > /dev/null


echo
echo "#####################################################"
echo "   HTML output generations finished successfully     "
echo "#####################################################"
echo
echo "You may issue: \"firefox ./tsung_results/report.html\""
