require 'sinatra'
require 'json'
require_relative '../infrastructure/http/controllers/auditoria_controller'

controller = Auditoria::Infrastructure::Http::Controllers::AuditoriaController.new

set :bind, '0.0.0.0'
set :port, 5003

before do
  content_type :json
end

get '/health' do
  JSON.generate(controller.health)
end

post '/events' do
  payload = JSON.parse(request.body.read)
  resultado = controller.crear(payload)

  if resultado.key?(:error)
    status 422
    JSON.generate(resultado)
  else
    status 201
    JSON.generate(resultado.transform_keys(&:to_s))
  end
end

get '/auditoria/:entidad_id' do
  entidad_id = params['entidad_id']
  resultado = controller.listar(entidad_id)

  if resultado.is_a?(Hash) && resultado.key?(:error)
    status 422
    JSON.generate(resultado)
  else
    JSON.generate(resultado)
  end
end

puts 'auditoria ready'
run! if __FILE__ == $PROGRAM_NAME
