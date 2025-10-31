require 'securerandom'
require 'json'
require_relative '../../domain/entities/factura'
require_relative '../../infrastructure/persistence/factura_record'

module Facturas
  module Application
    module UseCases
      class CrearFactura
        # Caso de uso Application responsable de crear facturas y delegar validaciones al dominio.

        def initialize(repository:, validator:, auditoria_gateway: nil, dian: nil, correo: nil, id_generator: -> { SecureRandom.uuid })
          @repository = repository
          @validator = validator
          @id_generator = id_generator
          @auditoria_gateway = auditoria_gateway
          @dian_gateway = dian
          @correo_gateway = correo
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

          cliente = validation.cliente

          factura = Facturas::Domain::Entities::Factura.new(
            id: @id_generator.call,
            cliente_id: validation.cliente_id,
            monto: validation.monto,
            fecha_emision: validation.fecha_emision
          )

          Facturas::Infrastructure::Persistence::FacturaRecord.transaction do
            persisted = @repository.save(factura)

            respuesta_dian = enviar_a_dian(persisted)
            if respuesta_dian
              persisted.dian_status = respuesta_dian[:status]
              persisted.dian_uuid = respuesta_dian[:dian_id]
              persisted.dian_response = respuesta_dian.to_json
              persisted.fecha_validacion_dian = Time.now.utc
              persisted = @repository.save(persisted)
              registrar_validacion(persisted)
            end

            correo_enviado = enviar_correo(cliente, persisted)
            registrar_notificacion(persisted) if correo_enviado
            registrar_creacion(persisted)

            persisted
          end
        end

        private

        def enviar_a_dian(factura)
          return unless @dian_gateway

          @dian_gateway.enviar_factura(factura.to_primitives)
        rescue StandardError => e
          warn "[WARN] Fallo al enviar a DIAN: #{e.message}"
          nil
        end

        def enviar_correo(cliente, factura)
          return false unless @correo_gateway && cliente&.email

          @correo_gateway.enviar_factura(cliente.email, factura.to_pdf)
          true
        rescue StandardError => e
          warn "[WARN] Fallo al enviar correo: #{e.message}"
          false
        end

        def registrar_validacion(factura)
          return unless @auditoria_gateway

          @auditoria_gateway.registrar_evento(
            servicio: 'facturas',
            entidad_id: factura.id,
            accion: 'VALIDAR',
            mensaje: 'Factura validada y aceptada por DIAN'
          )
        end

        def registrar_notificacion(factura)
          return unless @auditoria_gateway

          @auditoria_gateway.registrar_evento(
            servicio: 'facturas',
            entidad_id: factura.id,
            accion: 'NOTIFICAR',
            mensaje: 'Factura enviada por correo'
          )
        end

        def registrar_creacion(factura)
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
