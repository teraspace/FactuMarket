require_relative '../../domain/repositories/factura_repository'
require_relative '../../domain/entities/factura'
require_relative '../../domain/value_objects/monto'
require_relative '../../domain/value_objects/fecha_emision'
require_relative '../config/database'
require_relative 'factura_record'

module Facturas
  module Infrastructure
    module Persistence
      class FacturaRepositoryImpl < Facturas::Domain::Repositories::FacturaRepository
        # Implementación ActiveRecord de FacturaRepository para la capa Infrastructure.

        def initialize(record_class: FacturaRecord)
          @record_class = record_class
          Facturas::Infrastructure::Config::Database.establish_connection
        end

        def save(factura)
          record = record_class.find_or_initialize_by(id: factura.id.to_s)
          record.cliente_id = factura.cliente_id
          record.monto = factura.monto.to_decimal
          record.fecha_emision = factura.fecha_emision.to_date
          record.dian_status = factura.dian_status
          record.dian_uuid = factura.dian_uuid
          record.dian_response = factura.dian_response
          record.fecha_validacion_dian = factura.fecha_validacion_dian
          record.save!
          entity_from_record(record)
        end

        def find_by_id(id)
          record = record_class.find_by(id: id.to_s)
          record && entity_from_record(record)
        end

        def all_by_date_range(fecha_inicio, fecha_fin)
          scope = record_class.all
          scope = scope.with_fecha_inicio(fecha_inicio) if fecha_inicio
          scope = scope.with_fecha_fin(fecha_fin) if fecha_fin

          scope.order(:fecha_emision).map { |record| entity_from_record(record) }
        end

        private

        attr_reader :record_class

        def entity_from_record(record)
          Facturas::Domain::Entities::Factura.new(
            id: record.id,
            cliente_id: record.cliente_id,
            monto: Facturas::Domain::ValueObjects::Monto.new(record.monto),
            fecha_emision: Facturas::Domain::ValueObjects::FechaEmision.new(record.fecha_emision),
            created_at: record.created_at,
            dian_status: record.dian_status,
            dian_uuid: record.dian_uuid,
            dian_response: record.dian_response,
            fecha_validacion_dian: record.fecha_validacion_dian
          )
        end
      end
    end
  end
end
