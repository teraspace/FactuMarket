require 'sinatra/base'
require 'json'
require_relative '../infrastructure/http/controllers/auditoria_controller'
require_relative '../infrastructure/http/middleware/authentication_middleware'

module Auditoria
  module Interfaces
    class API < Sinatra::Base
      helpers do
        def controller
          settings.auditoria_controller
        end
      end

      configure do
        set :bind, '0.0.0.0'
        set :port, 5003
        set :auditoria_controller, Auditoria::Infrastructure::Http::Controllers::AuditoriaController.new
      end

      use Auditoria::Infrastructure::Http::Middleware::AuthenticationMiddleware

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
    end
  end
end

puts 'auditoria ready'
Auditoria::Interfaces::API.run! if __FILE__ == $PROGRAM_NAME
