require 'time'
require_relative '../value_objects/monto'
require_relative '../value_objects/fecha_emision'

module Facturas
  module Domain
    module Entities
      class Factura
        # Entidad de dominio que representa el agregado Factura dentro de la capa Domain.

        attr_reader :id, :cliente_id, :monto, :fecha_emision, :created_at
        attr_accessor :dian_status, :dian_uuid, :dian_response, :fecha_validacion_dian

        def initialize(id:, cliente_id:, monto:, fecha_emision:, created_at: nil, dian_status: nil, dian_uuid: nil, dian_response: nil, fecha_validacion_dian: nil)
          @id = id
          @cliente_id = cliente_id
          @monto = monto
          @fecha_emision = fecha_emision
          @created_at = normalize_created_at(created_at)
          @dian_status = dian_status
          @dian_uuid = dian_uuid
          @dian_response = dian_response
          @fecha_validacion_dian = normalize_time(fecha_validacion_dian)

          validate!
        end

        def to_primitives
          {
            id: id,
            cliente_id: cliente_id,
            monto: monto.to_f,
            fecha_emision: fecha_emision.to_s,
            created_at: created_at&.iso8601,
            dian_status: dian_status,
            dian_uuid: dian_uuid,
            dian_response: dian_response,
            fecha_validacion_dian: fecha_validacion_dian&.iso8601
          }
        end

        def to_pdf
          <<~PDF.gsub(/\n+/, "\n").strip
            FACTURA ##{id}
            Cliente ID: #{cliente_id}
            Monto: #{format('%.2f', monto.to_f)}
            Fecha emisión: #{fecha_emision.to_s}
            Generada: #{(created_at || Time.now.utc).iso8601}
          PDF
        end

        private

        def normalize_created_at(value)
          return value if value.nil? || value.is_a?(Time)

          Time.parse(value.to_s)
        rescue ArgumentError
          raise ArgumentError, 'created_at debe ser un tiempo válido'
        end

        def normalize_time(value)
          return nil if value.nil?
          return value if value.is_a?(Time)

          Time.parse(value.to_s)
        rescue ArgumentError
          raise ArgumentError, 'fecha_validacion_dian debe ser un tiempo válido'
        end

        def validate!
          raise ArgumentError, 'id requerido' if id.nil? || id.to_s.strip.empty?
          raise ArgumentError, 'cliente_id requerido' if cliente_id.nil? || cliente_id.to_s.strip.empty?
          unless monto.is_a?(Facturas::Domain::ValueObjects::Monto)
            raise ArgumentError, 'monto debe ser un ValueObject Monto'
          end
          unless fecha_emision.is_a?(Facturas::Domain::ValueObjects::FechaEmision)
            raise ArgumentError, 'fecha_emision debe ser un ValueObject FechaEmision'
          end
        end
      end
    end
  end
end
