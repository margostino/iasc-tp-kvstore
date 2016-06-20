defmodule KVStoreTest do
  use ExUnit.Case

  test "start supervised worker and put/get value" do
    value = %{name: "martin", age: 30}
    {:ok, sup_pid} = KVStore.Supervisor.start_link
    {:ok, worker_pid} = Supervisor.start_child(sup_pid, [:server])
    assert KVStore.put(:server, 1, value) == :ok
    assert KVStore.get(:server, 1) == {:ok, value}
  end

  test "broke supervised worker" do
    {:ok, sup_pid} = KVStore.Supervisor.start_link
    {:ok, worker_pid} = Supervisor.start_child(sup_pid, [:server])

    # Finish the server in an abnormal way
    GenServer.stop(:server, :kill)
    :timer.sleep(500)
    assert Process.alive?(Process.whereis(:server))

    # Finish the server in a normal way
    GenServer.stop(:server, :normal)
    :timer.sleep(500)
    assert Process.whereis(:server) == nil
  end

end
