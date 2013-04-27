#!/bin/sh
# je parametr složkou?
if [ $# -eq 1 ] && [ -d "$1" ]; then
	#existuje složka .le ? vymazat : vytvořit
	if [ -d "./.le/" ]; then
			rm .le/* 2> /dev/null
	else
		mkdir .le
	fi

	experimentalDir=`pwd`

	#existuje nějaký config ?
	if [ -r ".le/.config" ]; then
		configPath="$experimentalDir/.le/.config"
	elif [ -r "$1/.config" ]; then
		configPath="$1/.config"
	fi

	#zpracuj config
	if [ ! -z "$configPath" ]; then
		# zíkání řádků obsahujících ignore
		config=`cat "$configPath" | grep ignore`
		ignoreLines=`echo "$config" | cut -d ' ' -f2`

		if [ ! -z "$ignoreLines" ]; then
			ignoreLines=`echo "$ignoreLines" | tr '\n' '|' | head -c -1`
		fi
	fi

	if [ ! -z "$ignoreLines" ]; then
		files=`ls -1p "$1" | grep -v "/" | grep -vE "$ignoreLines"`
	else
		files=`ls -1p "$1" | grep -v "/"`
	fi

	if [ ! -z "$files" ]; then
		echo "$files" | while read file ;
		do
			cp "$1"/"$file" "$experimentalDir"/.le
			cp "$1"/"$file" "$experimentalDir"/
		done
	fi

	echo projdir "$1" | grep -v "^$" > .le/.config
	echo "$config" | grep -v "^$" >> .le/.config
else
	echo "Parametr není složka!" >&2;
	exit 1
fi

exit 0