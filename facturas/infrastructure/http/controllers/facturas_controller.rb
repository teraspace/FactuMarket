module Facturas
  module Infrastructure
    module Http
      module Controllers
        class FacturasController
          # Controlador HTTP en Infrastructure que orquesta casos de uso y serializa respuestas.

          def initialize(crear_factura:, obtener_factura:, listar_facturas:)
            @crear_factura = crear_factura
            @obtener_factura = obtener_factura
            @listar_facturas = listar_facturas
          end

          def health
            { 'status' => 'ok', 'service' => 'facturas' }
          end

          def create(request_dto)
            factura = @crear_factura.call(request_dto)
            serialize(factura)
          end

          def show(id)
            factura = @obtener_factura.call(id: id)
            factura ? serialize(factura) : nil
          end

          def list(fecha_inicio:, fecha_fin:)
            @listar_facturas.call(fecha_inicio: fecha_inicio, fecha_fin: fecha_fin)
                              .map { |factura| serialize(factura) }
          end

          private

          def serialize(factura)
            factura.to_primitives.transform_keys(&:to_s)
          end
        end
      end
    end
  end
end
