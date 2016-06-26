# iasc-tp-kvstore

Start Nodos (master/slaves)
iex --name master@127.0.0.1 -pa _build/dev/lib/kvstore/ebin/ --app kvstore --erl "-config config/master"
iex --name slave1@127.0.0.1 -pa _build/dev/lib/kvstore/ebin/ --app kvstore --erl "-config config/slave1"
iex --name slave2@127.0.0.1 -pa _build/dev/lib/kvstore/ebin/ --app kvstore --erl "-config config/slave2"
