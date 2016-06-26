defmodule KVStoreTest do
  use ExUnit.Case

  '''
  test "messages between nodes" do
    {:ok, sup_pid} = KVServer.Supervisor.start_link
    {:ok, _} = Supervisor.start_child(sup_pid, [:server])
    Node.spawn_link :server
    assert KVServer.ping(:server) == :pong
  end
  '''

  test "start supervised worker and put/get value" do
    #{:ok, sup_pid} = KVServer.AppNode.
    #{:ok, _} = Supervisor.start_child(sup_pid, [:server])
    #assert KVServer.put(:server, "key1", "value1") == :ok
    #assert KVServer.get(:server, "key1") == {:ok, "value1"}
  end
'''
  test "validate data type and size KV" do
    {:ok, sup_pid} = KVStore.Supervisor.start_link
    {:ok, _} = Supervisor.start_child(sup_pid, [:server])
    assert KVStore.put(:server, 1, "value1") == {:error, ["Key must be String"]}
    assert KVStore.put(:server, "key1", 3232) == {:error, ["Value must be String"]}
    assert KVStore.put(:server, 212, 3232) == {:error, ["Value must be String", "Key must be String"]}
    assert KVStore.put(:server, 212, 3232) == {:error, ["Value must be String", "Key must be String"]}
  end

  test "validate compare values" do
    {:ok, sup_pid} = KVStore.Supervisor.start_link
    {:ok, _} = Supervisor.start_child(sup_pid, [:server])
    assert KVStore.put(:server, "k1", "b") == :ok
    assert KVStore.filter(:server, "gt", "a") == {:ok, ["b"]}
    assert KVStore.filter(:server, "gtds", "a") == {:error, "Operator should be: gt, gte, lt or lte"}
  end

  test "broke supervised worker" do
    {:ok, sup_pid} = KVStore.Supervisor.start_link
    {:ok, _} = Supervisor.start_child(sup_pid, [:server])

    # Finish the server in an abnormal way
    GenServer.stop(:server, :kill)
    :timer.sleep(500)
    assert Process.alive?(Process.whereis(:server))

    # Finish the server in a normal way
    GenServer.stop(:server, :normal)
    :timer.sleep(500)
    assert Process.whereis(:server) == nil
  end
'''
end
