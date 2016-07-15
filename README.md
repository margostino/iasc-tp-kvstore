# TP IASC - KVStore Distribuido OTP

La aplicación en un implementa actores distribuidos: cluster de orquestadores y cluster de data nodes

Elementos:

* Aplicaciones
* Workers - GenServer en este caso
* Supervisores
* Alias locales y globales

## Uso

```bash
mix deps.get 
mix compile
```

## Levantar nodos de datos en tres terminales diferentes 

```bash
cd apps/worker 
iex --name dn1@127.0.0.1 -S mix run
```

```bash
cd apps/worker 
iex --name dn2@127.0.0.1 -S mix run
```

```bash
cd apps/worker 
iex --name dn3@127.0.0.1 -S mix run
```

## Parar probar la interface consola 

```bash
cd apps/store
iex --name store@127.0.0.1 -S mix run
```

```elixir
iex> KVStore.put("k1", "v1")
iex> KVStore.put("k2", "v2")
iex> KVStore.put("k3", "v3")
iex> KVStore.get("k3")
iex> KVStore.delete("k3")
iex> KVStore.keys()
iex> KVStore.values()
iex> KVStore.values_gt("v")
iex> KVStore.values_gte("v")
iex> KVStore.values_lte("v")
iex> KVStore.values_lt("v")
```

## Para probar la interface REST

### Levantar un cluster de nodos coordinadores 

```bash
iex --name cn1@127.0.0.1 --erl "-config config/cn1.config" -S mix run
```

```bash
iex --name cn2@127.0.0.1 --erl "-config config/cn2.config" -S mix run
```

```bash
iex --name cn3@127.0.0.1 --erl "-config config/cn3.config" -S mix run
```

Probar interface con curl (o cualquier cliente REST)

```bash
curl -X POST --data "key=key1&value=value1" http://localhost:8888/entries
curl -X POST --data "key=key2&value=value2" http://localhost:8888/entries
curl -X POST --data "key=key3&value=value3" http://localhost:8888/entries
curl -X GET http://localhost:8888/entries/key1
curl -X GET http://localhost:8888/entries/key3
curl -X GET http://localhost:8888/entries/noexiste
curl -X DELETE http://localhost:8888/entries/key1
curl -X GET http://localhost:8888/entries?values_gt=k
curl -X GET http://localhost:8888/entries?values_gte=k
curl -X GET http://localhost:8888/entries?values_lt=k
curl -X GET http://localhost:8888/entries?values_lte=k
```

###Luego: 

Deshabilitar cn1 y verificar que el coordinador que responde es cn2
Deshabilitar cn2 y verificar que el coordinador que responde es cn3


## TODO 

### scripts bash para levantar clusters, testing, refactoring, cliente http, integracion con branch ets, hacer que los nodos de coordinacion dependan desde el inicio de los nodos de datos(sync nodes en archivos config),etc
