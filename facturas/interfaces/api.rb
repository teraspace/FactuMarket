require 'sinatra/base'
require 'json'

require_relative '../infrastructure/http/middleware/authentication_middleware'

%w[../domain ../application ../infrastructure].each do |path|
  Dir[File.expand_path("#{path}/**/*.rb", __dir__)].sort.each { |file| require file }
end

module Facturas
  module Interfaces
    class API < Sinatra::Base
      # API Sinatra en la capa Interfaces que expone los endpoints REST del servicio Facturas.

      set :bind, '0.0.0.0'
      set :port, 5002
      set :server, :puma

      use Facturas::Infrastructure::Http::Middleware::AuthenticationMiddleware

      configure do
        repository = Facturas::Infrastructure::Persistence::FacturaRepositoryImpl.new
        validator = Facturas::Domain::Services::ValidarFactura.new
        auditoria = Facturas::Infrastructure::Services::AuditoriaGateway.new
        dian = Facturas::Infrastructure::External::DianHttpClient.new
        correo = Facturas::Infrastructure::External::EmailClient.new

        crear_factura = Facturas::Application::UseCases::CrearFactura.new(
          repository: repository,
          validator: validator,
          auditoria_gateway: auditoria,
          dian: dian,
          correo: correo
        )
        obtener_factura = Facturas::Application::UseCases::ObtenerFactura.new(repository: repository)
        listar_facturas = Facturas::Application::UseCases::ListarFacturas.new(repository: repository)

        set :facturas_controller, Facturas::Infrastructure::Http::Controllers::FacturasController.new(
          crear_factura: crear_factura,
          obtener_factura: obtener_factura,
          listar_facturas: listar_facturas
        )
      end

      helpers do
        def controller
          settings.facturas_controller
        end

        def parse_json_body
          request.body.rewind
          raw_body = request.body.read
          return {} if raw_body.nil? || raw_body.strip.empty?

          JSON.parse(raw_body)
        rescue JSON::ParserError
          halt 400, JSON.generate('error' => 'payload JSON inválido')
        end
      end

      before do
        content_type 'application/json'
      end

      get '/health' do
        JSON.generate(controller.health)
      end

      post '/facturas' do
        payload = parse_json_body
        request_dto = Facturas::Application::DTO::FacturaRequest.from_hash(payload)
        factura = controller.create(request_dto)

        status 201
        headers 'Location' => "/facturas/#{factura['id']}"
        JSON.generate(factura)
      rescue Facturas::Domain::Services::ValidarFactura::ValidationError, ArgumentError => e
        status 422
        JSON.generate('error' => e.message)
      end

      get '/facturas/:id' do
        factura = controller.show(params[:id])
        if factura
          JSON.generate(factura)
        else
          status 404
          JSON.generate('error' => 'factura no encontrada')
        end
      rescue ArgumentError => e
        status 400
        JSON.generate('error' => e.message)
      end

      get '/facturas' do
        facturas = controller.list(
          fecha_inicio: params['fechaInicio'],
          fecha_fin: params['fechaFin']
        )

        JSON.generate(facturas)
      rescue ArgumentError => e
        status 422
        JSON.generate('error' => e.message)
      end
    end
  end
end

Facturas::Interfaces::API.run! if __FILE__ == $PROGRAM_NAME
