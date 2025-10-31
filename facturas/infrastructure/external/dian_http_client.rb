require 'net/http'
require 'json'
require 'securerandom'
require_relative 'dian_gateway'

module Facturas
  module Infrastructure
    module External
      class DianHttpClient < DianGateway
        # Cliente HTTP simulado que envía facturas a la DIAN (mock).

        def enviar_factura(factura)
          uri = URI.parse('https://api.mock-dian.gov.co/facturas')
          request = Net::HTTP::Post.new(uri)
          request['Content-Type'] = 'application/json'
          request.body = JSON.generate(factura)

          # Simulación de envío; en un escenario real se ejecutaría Net::HTTP.start.
          puts "[INFO] Factura enviada (mock) a la DIAN: #{factura[:id] || factura['id']}"

          {
            status: 'ACEPTADO',
            codigo: '200',
            dian_id: SecureRandom.uuid,
            mensaje: 'Factura validada correctamente',
            fecha_recepcion: Time.now.utc.iso8601
          }
        end
      end
    end
  end
end
