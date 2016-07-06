> TP IASC KVStore Distribuido OTP

La aplicación en un implementa actores distribuidos: cluster de orquestadores y cluster de data nodes

Elementos:

* Aplicaciones
* Workers - GenServer en este caso
* Supervisores
* Alias locales y globales

## Levantando una sóla VM

```bash
iex -S mix
```

## Levantando múltiples VMs


```bash
iex --sname foo -S mix
```

Luego se pueden utilizar las siguientes herramientas para hacer comunicación entre VMs:

* `Node.spawn`
* `:rpc.call`

## Levantando múltiples VMs

```bash
iex --name master@127.0.0.1 --cookie cookie -pa _build/dev/lib/kvstore/ebin/ --app kvstore --erl "-config config/master"
iex --name slave1@127.0.0.1 --cookie cookie -pa _build/dev/lib/kvstore/ebin/ --app kvstore --erl "-config config/slave1"
iex --name slave2@127.0.0.1 --cookie cookie -pa _build/dev/lib/kvstore/ebin/ --app kvstore --erl "-config config/slave2"
```

Probar matar una vm y ver que después el proceso renace en la siguiente de menor prioridad

## Conectar un cliente por cookie

```bash
$ iex --name client@127.0.0.1 --cookie cookie
> Node.spawn_link :"master@127.0.0.1", fn -> [] end
> Node.list
> Node.ping :"master@127.0.0.1"
> GenServer.call({:global, KVStore.Api}, {:get, "1"})
```
