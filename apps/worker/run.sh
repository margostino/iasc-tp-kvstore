if [ $# -ne 1 ]; then
	echo "Enter worker name"
	exit 1
fi
iex --name dn${1}@127.0.0.1 -S mix
