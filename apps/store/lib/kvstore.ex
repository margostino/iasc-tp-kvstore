defmodule KVStore do

  require Logger

  import GenServer 

  ######### API #############

  def put(key, value) do
    KVStore.Worker.put(worker(key), key, value)
  end

  def get(key) do
    KVStore.Worker.get(worker(key), key)
  end 

  def delete(key) do
    KVStore.Worker.delete(worker(key), key)
  end

  def filter(operator, value) do 

    # Llamada en paralelo a todos los workers(o particiones) del cluster 
    # Funciona para ir probando pero no escala

    multi_call(datanodes(), KVStore.Worker, {:filter, operator, value}, max_wait()) 
      |> do_filter()

  end 

  ########### private  ########### 

  defp do_filter({replies, []}) do 
    {:ok, collect(replies)}
  end

  defp do_filter({[r|replies], [f|fnodes]}) do
    {:partial_response, collect([r|replies])}
  end

  defp do_filter({[], [f|fnodes]}) do
    {:error, :no_response}    
  end

  defp collect(replies) do 

    replies 
      |> Enum.map(fn({node,{:ok, sublist}}) -> sublist end)
      |> List.flatten()

  end

  defp datanodes() do
    Application.get_env(:store, :datanodes)
  end

  defp max_wait() do 
    :timer.seconds(Application.get_env(:store, :max_wait))
  end 

  defp find_datanode(key) do
    Enum.at(datanodes(), 
      :erlang.phash2(key, length(datanodes())))
  end

  defp worker(key) do
    {KVStore.Worker, find_datanode(key)}
  end

end
