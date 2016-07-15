use Mix.Config

config :store, 
	datanodes: [
		:"dn1@127.0.0.1", 
		:"dn2@127.0.0.1",
		:"dn3@127.0.0.1"
	], 
	remote_worker_alias: :data_worker, 
	max_key_size: 10, 
	max_value_size: 100
	