require 'net/http'
require 'json'
require 'uri'
require_relative '../persistence/outbox_event'

module Facturas
  module Infrastructure
    module Workers
      class RelayOutboxWorker
        AUDITORIA_URL = ENV.fetch('AUDITORIA_URL', 'http://auditoria:5003/events')

        def perform
          puts "[INFO] Iniciando procesamiento de outbox events..."
          Facturas::Infrastructure::Persistence::OutboxEvent.pending.find_each do |event|
            begin
              send_event(event)
              event.update!(status: 'processed', processed_at: Time.now.utc)
              puts "[INFO] Evento procesado: #{event.id}"
            rescue StandardError => e
              event.update!(status: 'failed')
              warn "[WARN] Error procesando evento #{event.id}: #{e.message}"
            end
          end
        end

        private

        def send_event(event)
          uri = URI.parse(AUDITORIA_URL)
          request = Net::HTTP::Post.new(uri)
          request['Content-Type'] = 'application/json'
          request.body = event.payload

          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
            http.request(request)
          end

          unless response.code.to_i.between?(200, 299)
            raise "HTTP #{response.code}"
          end
        end
      end
    end
  end
end
