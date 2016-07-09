defmodule Rest.Kvs do

	use Maru.Router

	namespace :kvs do 

		route_param :key do

			get do
				json(conn, response(KVStore.get(params[:key])))
			end

			delete do
				json(conn, response(KVStore.delete(params[:key])))
			end

		end

		params do
			requires :key, type: String
			requires :value, type: String
		end
		post do
			json(conn, response(KVStore.put(params[:key], params[:value])))
		end

	end

	def response({code, data_or_reason}) do
		%{code: code, data_or_reason: data_or_reason}
	end

end


defmodule Rest do

	use Maru.Router

	before do
		plug Plug.Logger
		plug Plug.Parsers,
		pass: ["*/*"],
		json_decoder: Poison,
		parsers: [:urlencoded, :json, :multipart]
	end

	mount Rest.Kvs

	rescue_from :all, as: e do
		json(conn, inspect(e)) 
	end


end
