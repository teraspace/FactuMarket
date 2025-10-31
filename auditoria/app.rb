require 'sinatra'
require 'json'
require 'mongo'
require 'socket'
require 'timeout'

def establish_mongo_connection(service_name)
  mongo_uri = ENV.fetch('MONGO_URI', 'mongodb://mongo-db:27017/factumarket')

  client = Mongo::Client.new(mongo_uri, server_selection_timeout: 5)
  begin
    client.database_names
    puts "#{service_name} conectado a MongoDB en #{mongo_uri}"
  ensure
    client&.close
  end
rescue StandardError => e
  warn "#{service_name} no pudo conectar a MongoDB: #{e.message}"
end

def probe_oracle_endpoint(service_name)
  raw_endpoint = ENV.fetch('ORACLE_CONN', 'oracle-db:1521')
  endpoint = raw_endpoint.split('@').last || raw_endpoint
  host_port = endpoint.split('/').first || endpoint
  host, port = host_port.split(':')
  port = port ? port.to_i : 1521

  Timeout.timeout(5) do
    TCPSocket.new(host, port).close
    puts "#{service_name} detectó Oracle accesible en #{host}:#{port}"
  end
rescue StandardError => e
  warn "#{service_name} no pudo validar Oracle: #{e.message}. Considere un reemplazo con SQLite en entornos ARM."
end

configure do
  set :bind, '0.0.0.0'
  set :port, 5003
  set :server, :puma
  STDOUT.sync = true

  service_name = 'auditoria'
  establish_mongo_connection(service_name)
  probe_oracle_endpoint(service_name)

  puts "#{service_name} ready"
  # Si Oracle no está disponible, considerar reemplazar por SQLite para pruebas locales.
end

get '/health' do
  content_type :json
  { status: 'ok', service: 'auditoria' }.to_json
end

get '/' do
  content_type :json
  { message: 'Servicio de auditoría operativo' }.to_json
end
