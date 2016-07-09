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

## Probar la interface consola 

### Levantar un nodo coordinador en una terminal 

```bash
cd apps/store
iex --name cn1@127.0.0.1 -S mix run
```

```elixir
iex> KVStore.put("key1", "value1")
iex> KVStore.put("key2", "value2")
iex> KVStore.put("key3", "tres")
iex> KVStore.get("key1")
iex> KVStore.delete("key1")
iex> KVStore.filter("gt", "a")
iex> KVStore.filter("gte", "a")
iex> KVStore.filter("lt", "a")
iex> KVStore.filter("lte", "a")
```

## Probar la interface REST

### Deshabilitar el nodo coordinador anterior y levantar la aplicación rest 

```bash
cd apps/rest
iex --name cn1@127.0.0.1 -S mix run
```
Probar interface con curl (o cualquier cliente REST)

```bash
curl -X POST --data "key=key1&value=value1" http://localhost:8888/kvs
curl -X POST --data "key=key3&value=value3" http://localhost:8888/kvs
curl -X GET http://localhost:8888/kvs/key1
curl -X GET http://localhost:8888/kvs/key3
curl -X GET http://localhost:8888/kvs/noexiste
curl -X DELETE http://localhost:8888/kvs/key1
```

## TODO 

### scripts y archivos de config para armar clusters en umbrella apps
### error handling, nodos caídos, etc
