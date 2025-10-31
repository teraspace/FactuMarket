module Auditoria
  module Domain
    module Entities
      class Evento
        # Entidad del dominio que representa un evento de auditoría registrado en el sistema.

        attr_reader :servicio, :entidad_id, :accion, :mensaje, :timestamp

        def initialize(servicio:, entidad_id:, accion:, mensaje:, timestamp:)
          @servicio = servicio
          @entidad_id = entidad_id
          @accion = accion
          @mensaje = mensaje
          @timestamp = timestamp
        end

        def to_h
          {
            servicio: servicio,
            entidad_id: entidad_id,
            accion: accion,
            mensaje: mensaje,
            timestamp: timestamp
          }
        end
      end
    end
  end
end
