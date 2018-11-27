#!/bin/bash

DEFAULT_RESPONSE="HTTP/1.1 200 OK\r\nConnection: close\r\n\r\n"
CUR=$(pwd)

while true; do
	HOOK=$(echo -en ${RESPONSE:-$DEFAULT_RESPONSE} | nc -l ${PORT:-9000} | head -n 4)

	if echo $HOOK | sed -n '
		1s/^POST \/.+ HTTP\/1.1$//p
		4s/^GitHub-Hookshot\/\.+$//p
	' | test; then
		# Pull to the corresponding repository
		DIR=$(hook | head -n 1 | awk '$2' | sed -e 's/\.\.//')
		cd "$CUR$DIR" \
			&& git pull \
			&& echo "Successfully 'git pull'ed from $PWD" \
			|| echo "An error occured while you attempted to 'git pull' from the directory '$DIR'"
	fi
done
