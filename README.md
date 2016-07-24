# TP IASC - KVStore Distribuido OTP

La aplicación en un implementa actores distribuidos: cluster de orquestadores y cluster de data nodes

Elementos:

* Aplicaciones
* Workers - GenServer en este caso
* Supervisores
* Alias locales y globales

## Modo de uso

### Obtención de dependencias y compilación en raíz del proyecto

```bash
mix deps.get
mix compile
```

### Levantar nodos de datos en tres terminales diferentes

```bash
cd apps/worker
./run.sh 1
```

```bash
cd apps/worker
./run.sh 2
```

```bash
cd apps/worker
./run.sh 3
```

### Para probar la interface consola (CLI)

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

### Para probar la interface REST

#### Levantar un cluster de nodos coordinadores

```bash
./runNode.sh 1
```

```bash
./runNode.sh 2
```

```bash
./runNode.sh 3
```

#### Probar interface con curl (o cualquier cliente REST)
Para ello se pueden ejecutar sentencias desde línea de comando o previamente, para agergar datos, ejecutar el script "populateREST.sh [cantidad_de_valores]" para agregar elementos

```bash
curl -X POST --data "key=key1&value=value1" http://localhost:8888/entries
curl -X POST --data "key=key2&value=value2" http://localhost:8888/entries
curl -X POST --data "key=key3&value=value3" http://localhost:8888/entries
curl -X GET http://localhost:8888/entries/key1
curl -X GET http://localhost:8888/entries/key3
curl -X DELETE http://localhost:8888/entries/key1
curl -X GET http://localhost:8888/entries/key1
curl -X GET http://localhost:8888/entries?values_gt=value2
curl -X GET http://localhost:8888/entries?values_gte=value2
curl -X GET http://localhost:8888/entries?values_lt=value2
curl -X GET http://localhost:8888/entries?values_lte=value2
```

#### Para probar el mecanismo de failover/takeover:

- Deshabilitar cn1 y volver a realizar la prueba anterior para verificar que el coordinador que responde es cn2
- Deshabilitar cn2 y volver a realizar la prueba anterior para verificar que el coordinador que responde es cn3
- Iniciar nuevamente cn1 y cn2, volver a realizar la prueba anterior para verificar que el coordinador que responde es cn1
