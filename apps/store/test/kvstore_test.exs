defmodule KVStoreTest do
  
  use ExUnit.Case

  test "validate data type and size KV" do
    assert KVStore.put(1, "value1") == {:error, ["Key must be String"]}
    assert KVStore.put("key1", 3232) == {:error, ["Value must be String"]}
    assert KVStore.put(212, 3232) == {:error, ["Value must be String", "Key must be String"]}
    assert KVStore.put(212, 3232) == {:error, ["Value must be String", "Key must be String"]}
  end

  test "validate compare values" do
    assert KVStore.put("k1", "b") == :ok
    assert KVStore.filter("gt", "a") == {:ok, ["b"]}
    assert KVStore.filter("gtds", "a") == {:error, "Operator should be: gt, gte, lt or lte"}
  end

  test "test delete key" do
    assert KVStore.put("k1", "b") == :ok
    assert KVStore.delete("k1") == :ok
  end

end
