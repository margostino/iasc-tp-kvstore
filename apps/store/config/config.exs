use Mix.Config

config :store, 
	datanodes: [
		:"dn1@127.0.0.1", 
		:"dn2@127.0.0.1",
		:"dn3@127.0.0.1"
	], 
	max_wait: 3 #seconds