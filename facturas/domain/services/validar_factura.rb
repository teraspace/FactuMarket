require_relative '../entities/cliente'
require_relative '../value_objects/monto'
require_relative '../value_objects/fecha_emision'

module Facturas
  module Domain
    module Services
      class ValidarFactura
        # Servicio de dominio que aplica reglas e invariantes previas a la creación de facturas.

        class ValidationError < StandardError; end

        Result = Struct.new(:cliente_id, :monto, :fecha_emision, keyword_init: true)

        DEFAULT_CLIENTS = {
          '1' => 'Cliente Demo',
          '123' => 'Cliente Principal'
        }.freeze

        def initialize(clientes: DEFAULT_CLIENTS)
          @clientes = clientes.transform_keys(&:to_s)
        end

        def call(cliente_id:, monto:, fecha_emision:)
          cliente = validar_cliente(cliente_id)
          monto_vo = Facturas::Domain::ValueObjects::Monto.new(monto)
          fecha_vo = Facturas::Domain::ValueObjects::FechaEmision.new(fecha_emision)

          Result.new(
            cliente_id: cliente.id,
            monto: monto_vo,
            fecha_emision: fecha_vo
          )
        rescue ArgumentError => e
          raise ValidationError, e.message
        end

        private

        def validar_cliente(cliente_id)
          id_normalizado = cliente_id.to_s.strip
          raise ValidationError, 'cliente_id es requerido' if id_normalizado.empty?

          nombre = @clientes[id_normalizado]
          raise ValidationError, 'cliente_id no válido' unless nombre

          Facturas::Domain::Entities::Cliente.new(id: id_normalizado, nombre: nombre)
        end
      end
    end
  end
end
