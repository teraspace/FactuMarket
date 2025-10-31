require 'time'
require_relative '../../domain/entities/evento'

module Auditoria
  module Application
    module UseCases
      class RegistrarEvento
        # Caso de uso Application que valida y persiste eventos de auditoría.

        REQUIRED_FIELDS = %w[servicio entidad_id accion mensaje].freeze

        def initialize(repository)
          @repository = repository
        end

        def call(payload)
          validate_payload!(payload)

          evento = Auditoria::Domain::Entities::Evento.new(
            servicio: payload['servicio'],
            entidad_id: payload['entidad_id'],
            accion: payload['accion'],
            mensaje: payload['mensaje'],
            timestamp: (payload['timestamp'] ? Time.parse(payload['timestamp']) : Time.now.utc).iso8601
          )

          @repository.save(evento.to_h)
          evento
        end

        private

        def validate_payload!(payload)
          missing = REQUIRED_FIELDS.reject { |field| present?(payload[field]) }
          raise ArgumentError, "Campos faltantes: #{missing.join(', ')}" unless missing.empty?
        end

        def present?(value)
          !value.nil? && !(value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end
