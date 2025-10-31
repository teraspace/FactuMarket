require 'net/http'
require 'json'
require 'uri'
require 'time'

module Facturas
  module Infrastructure
    module Services
      class AuditoriaGateway
        # Gateway HTTP hacia el microservicio de auditoría para registrar eventos de dominio.

        def initialize(base_url: ENV.fetch('AUDITORIA_URL', 'http://auditoria:5003'))
          @base_url = base_url
        end

        def registrar_evento(servicio:, entidad_id:, accion:, mensaje:)
          uri = URI.join(base_url_with_slash, 'eventos')
          payload = {
            servicio: servicio,
            entidad_id: entidad_id,
            accion: accion,
            mensaje: mensaje,
            timestamp: Time.now.utc.iso8601
          }

          request = Net::HTTP::Post.new(uri)
          request['Content-Type'] = 'application/json'
          request.body = JSON.generate(payload)

          response = http_client(uri).request(request)
          response.is_a?(Net::HTTPSuccess)
        rescue StandardError => e
          warn "[auditoria] No fue posible registrar evento: #{e.message}"
          false
        end

        private

        attr_reader :base_url

        def base_url_with_slash
          base_url.end_with?('/') ? base_url : "#{base_url}/"
        end

        def http_client(uri)
          Net::HTTP.new(uri.host, uri.port).tap do |http|
            http.use_ssl = uri.scheme == 'https'
            http.open_timeout = 2
            http.read_timeout = 2
          end
        end
      end
    end
  end
end
