#/bin/bash
for i in "$@";do
	echo "**************************************************"
	echo $i
	echo
	grep --color=always -A 2 -B 2 -n -P '(?<!^)POC|^POC.*,,|\<not\ counted\>' $i
	echo
done

