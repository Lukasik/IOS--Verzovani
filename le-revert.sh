#!/bin/sh

config=`cat ".le/.config" | grep ignore`
ignoreLines=`echo "$config" | cut -d ' ' -f2`

if [ ! -z "$ignoreLines" ]; then
	ignoreLines=`echo "$ignoreLines" | tr '\n' '|' | head -c -1`
fi

paramNum=$#

if [ $# -ge 1 ]; then
	while [ $paramNum -gt 0 ]
	do
		if [ ! -z "$files" ]; then
			files=`printf '%s\n%s' "$files" "$1"`
		else
			files="$1"
		fi
		paramNum=`expr $paramNum - 1`
		shift
	done

	files=`echo "$files" | grep -vE '^\\.'`
else
	files=`ls -1p ".le/" | grep -v "/"`
fi

if [ ! -z "$ignoreLines" ]; then
	files=`echo "$files" | grep -vE "$ignoreLines"`
fi

if [ ! -z "$files" ]; then
	echo "$files" | while read file ;
	do
		cp -f ".le/$file" ./ >&2
	done
fi

exit 0