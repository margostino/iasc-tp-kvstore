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

## Probar la interface REST

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
curl -X POST --data "key=key1&value=value1" http://localhost:8888/kvs
curl -X POST --data "key=key3&value=value3" http://localhost:8888/kvs
curl -X GET http://localhost:8888/kvs/key1
curl -X GET http://localhost:8888/kvs/key3
curl -X GET http://localhost:8888/kvs/noexiste
curl -X DELETE http://localhost:8888/kvs/key1
```

Luego: 

Deshabilitar cn1 y verificar que el coordinador que responde es cn2
Deshabilitar cn2 y verificar que el coordinador que responde es cn3


## TODO 

### error handling, nodos caídos, etc
