if [ $# -ne 1 ]; then
	echo "Enter node id"
	exit 1
fi
iex --name cn${1}@127.0.0.1 --erl "-config config/cn${1}.config" -S mix run
