use Mix.Config

import_config "../apps/*/config/config.exs"


config :logger, 
	backends: [:console],
 	format: "\n-- $time $metadata[$level] $levelpad$message --\n"
