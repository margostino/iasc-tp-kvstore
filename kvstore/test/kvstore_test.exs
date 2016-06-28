defmodule KVStoreTest do
  use ExUnit.Case

  test "validate data type and size KV" do
    assert KVStore.Api.put(1, "value1") == {:error, ["Key must be String"]}
    assert KVStore.Api.put("key1", 3232) == {:error, ["Value must be String"]}
    assert KVStore.Api.put(212, 3232) == {:error, ["Value must be String", "Key must be String"]}
    assert KVStore.Api.put(212, 3232) == {:error, ["Value must be String", "Key must be String"]}
  end

  test "validate compare values" do
    assert KVStore.Api.put("k1", "b") == :ok
    assert KVStore.Api.filter("gt", "a") == {:ok, ["b"]}
    assert KVStore.Api.filter("gtds", "a") == {:error, "Operator should be: gt, gte, lt or lte"}
  end

end
