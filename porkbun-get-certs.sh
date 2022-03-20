#!/bin/bash -e
set -euo pipefail

usage() {
	echo "Usage: $0 -p api_public -s api_secret [-d <directory>] domain1 domain2 ..." >&2
	exit 1
}

extract() {
	echo "$reply"
}

public_key=""
secret_key=""
directory=/etc/ssl/porkbun
while getopts "p:s:d:" opt; do
	case $opt in
		p)
			public_key="${OPTARG}"
			if [[ ! "$public_key" =~ ^pk1_[0-9a-fA-F]{64}$ ]]; then
				echo "Invalid public key" >&2
				exit 1
			fi
			;;

		s)
			secret_key="${OPTARG}"
			if [[ ! "$secret_key" =~ ^sk1_[0-9a-fA-F]{64}$ ]]; then
				echo "Invalid secret key" >&2
				exit 1
			fi
			;;

		d)
			directory="${OPTARG}"
			;;

		*)
			usage
			;;
	esac
done

if [ -z "$public_key" ] || [ -z "$secret_key" ] || [ -z "$directory" ]; then
	usage
fi

shift $((OPTIND-1))

for domain in "$@"; do
	if [[ ! "$domain" =~ ^([a-z0-9-]+\.)+[a-z]{2,}$ ]]; then
		echo "Invalid domain \"$domain\"" >&2
		exit 1
	fi
done

for domain in "$@"; do
	req="{\"apikey\":\"${public_key}\",\"secretapikey\":\"${secret_key}\"}"
	reply=$(curl --silent --data-raw "$req" -H "Content-Type: application/json" "https://porkbun.com/api/json/v3/ssl/retrieve/${domain}")
	case $(echo "$reply" | jq -r .status) in
		SUCCESS)
			;;

		ERROR)
			message=$(echo "$reply" | jq -r .message)
			echo "Failed to fetch $domain: $message" >&2
			exit 1
			;;

		*)
			echo "Unexpected reply from server: $reply"
			exit 1
	esac

	mkdir -p "$directory/$domain"

	privfile="$directory/$domain/private.pem"
	touch "$privfile"
	chmod 600 "$privfile"
	echo "$reply" | jq -r .privatekey >"$privfile"

	chainfile="$directory/$domain/chain.pem"
	touch "$chainfile"
	chmod 644 "$chainfile"
	echo "$reply" | jq -r .certificatechain >"$chainfile"
done
