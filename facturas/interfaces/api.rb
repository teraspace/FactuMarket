require 'sinatra/base'

module Facturas
  module Interfaces
    class API < Sinatra::Base
      # API Sinatra en la capa Interfaces que expone los endpoints REST del servicio Facturas.

      set :bind, '0.0.0.0'
      set :port, 5002

      get '/health' do
        # Endpoint de lectura para monitoreo del servicio.
        status 200
        body ''
      end

      post '/facturas' do
        # Endpoint REST para crear facturas delegando al caso de uso correspondiente.
        status 202
        body ''
      end

      get '/facturas/:id' do
        # Endpoint REST para recuperar una factura específica mediante su identificador.
        status 200
        body ''
      end

      get '/facturas' do
        # Endpoint REST para listar facturas filtradas por fechaInicio y fechaFin.
        status 200
        body ''
      end
    end
  end
end

Facturas::Interfaces::API.run! if __FILE__ == $PROGRAM_NAME
