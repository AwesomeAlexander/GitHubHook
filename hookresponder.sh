#!/bin/bash

DEFAULT_RESPONSE="HTTP/1.1 200 OK\r\nConnection: close\r\n\r\n"
CUR=$(pwd)

while true; do
	HOOK=$(echo -en "${RESPONSE:-$DEFAULT_RESPONSE}" \
		| nc -l ${PORT:-9000}) 
	
	echo -e "Recieved Request:\n\n$(echo "$HOOK" | sed -ne '1,/^$/p')"

	if echo "$HOOK" | sed -n '
		1s/^POST \/.+ HTTP\/1.1$//p
		4s/^GitHub-Hookshot\/\.+$//p
	' | test; then
		# Pull to the corresponding repository
		DIR=$(echo "$HOOK" | head -n 1 | awk '$2' | sed -e 's/\.\.//')
		cd "$CUR$DIR" \
			&& git pull \
			&& echo "Successfully 'git pull'ed from $PWD" \
			|| echo "An error occured while you attempted to 'git pull' from
					the directory '$CUR$DIR'"
	fi

	echo -e "\n====================================================\n"
done
