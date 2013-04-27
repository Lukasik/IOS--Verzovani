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
	refdirFiles=`ls -1p .le/`
	files=`printf '%s\n%s\n%s' "$experimentaldirFiles" "$projdirFiles" "$refdirFiles" | grep -v "/"`
else
	paramNum=$#
	while [ $paramNum -gt 0 ]
	do
		if [ ! -z "$files" ]; then
			files=`echo "$files"'\n'"$1"`
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
		if [ -r "$projdir"/"$file" ] && [ -r .le/"$file" ] && [ -r "$file" ]; then
			#porovnávání změn
			projRef=`diff -u "$projdir"/"$file" .le/"$file"`
			projExp=`diff -u "$projdir"/"$file" "$file"`
			refExp=`diff -u .le/"$file" "$file"`

			if [ -z "$projRef" ] && [ -z "$refExp" ]; then
				echo .: "$file"
			elif [ -z "$projRef" ] && [ ! -z "$refExp" ]; then
				echo M: "$file"
			elif [ -z "$projExp" ] && [ ! -z "$refExp" ]; then
				cp -f "$projdir"/"$file" .le/
				echo UM: "$file"
			elif [ -z "$refExp" ] && [ ! -z "$projRef" ]; then
				cp -f "$projdir"/"$file" .le/
				cp -f "$projdir"/"$file" .
				echo U: "$file"
			elif [ ! -z "$refExp" ] && [ ! -z "$projRef" ] && [ ! -z "$projExp" ]; then
				diff -u ".le/$file" "$projdir"/"$file" | patch -f "$file" > /dev/null

				if [ $? -eq 0 ]; then
					#uložení výsledku
					cp -f "$projdir"/"$file" .le/"$file"
					echo M+: "$file"
				else
					rm -f *.rej *.orig
					echo M!: "$file" conflict!
					# exit 1
				fi
			fi
		elif [ -r "$projdir"/"$file" ] && [ ! -r "$file" ]; then
			cp -f "$projdir"/"$file" .
			cp -f "$projdir"/"$file" .le/
			echo C: "$file"
		elif [ ! -r "$projdir"/"$file" ] && [ -r .le/"$file" ]; then
			rm -f "$file"
			rm -f .le/"$file"
			echo D: "$file"
		fi
	done
fi

exit 0