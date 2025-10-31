require 'securerandom'
require_relative '../../domain/entities/factura'

module Facturas
  module Application
    module UseCases
      class CrearFactura
        # Caso de uso Application responsable de crear facturas y delegar validaciones al dominio.

        def initialize(repository:, validator:, auditoria_gateway: nil, dian: nil, id_generator: -> { SecureRandom.uuid })
          @repository = repository
          @validator = validator
          @id_generator = id_generator
          @auditoria_gateway = auditoria_gateway
          @dian_gateway = dian
        end

        def call(request)
          unless request.respond_to?(:cliente_id) && request.respond_to?(:monto) && request.respond_to?(:fecha_emision)
            raise ArgumentError, 'request inválido'
          end

          validation = @validator.call(
            cliente_id: request.cliente_id,
            monto: request.monto,
            fecha_emision: request.fecha_emision
          )

          factura = Facturas::Domain::Entities::Factura.new(
            id: @id_generator.call,
            cliente_id: validation.cliente_id,
            monto: validation.monto,
            fecha_emision: validation.fecha_emision
          )

          persisted = @repository.save(factura)
          enviar_a_dian(persisted)
          registrar_auditoria(persisted)
          persisted
        end

        private

        def enviar_a_dian(factura)
          return unless @dian_gateway

          @dian_gateway.enviar_factura(factura.to_primitives)
        rescue StandardError => e
          warn "[WARN] Fallo al enviar a DIAN: #{e.message}"
        end

        def registrar_auditoria(factura)
          return unless @auditoria_gateway

          @auditoria_gateway.registrar_evento(
            servicio: 'facturas',
            entidad_id: factura.id,
            accion: 'CREAR',
            mensaje: 'Factura creada exitosamente'
          )
        end
      end
    end
  end
end
