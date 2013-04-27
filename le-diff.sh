#!/bin/sh
projdir=`cat ".le/.config" | grep projdir | cut -d ' ' -f2-`

config=`cat ".le/.config" | grep ignore`
ignoreLines=`echo "$config" | cut -d ' ' -f2-`

if [ ! -z "$ignoreLines" ]; then
	ignoreLines=`echo "$ignoreLines" | tr '\n' '|' | head -c -1`
fi

if [ $# -eq 0 ]; then
	experimentaldirFiles=`ls -1p`
	projdirFiles=`ls -1p "$projdir"`
	files=`printf '%s\n%s' "$experimentaldirFiles" "$projdirFiles" | grep -v "/"`
else
	paramNum=$#
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

	files=`echo "$files"| grep -vE '^\\.'`
fi

files=`echo "$files" | sort | uniq`

if [ ! -z "$ignoreLines" ]; then
	files=`echo "$files" | grep -vE "$ignoreLines"`
fi

if [ ! -z "$files" ]; then
	echo "$files" | while read file ;
	do
		if [ -r "$file" ] && [ -r "$projdir/$file" ]; then
			changes=`diff -u "$projdir/$file" "$file"`

			if [ ! -z "$changes" ]; then
				echo "$changes"
			else
				echo .: "$file"
			fi

		elif [ -r "$projdir/$file" ]; then
			echo C: "$file"
		else
			echo D: "$file"
		fi
	done
fi

exit 0