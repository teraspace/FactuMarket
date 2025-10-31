require_relative '../entities/cliente'
require_relative '../value_objects/monto'
require_relative '../value_objects/fecha_emision'

module Facturas
  module Domain
    module Services
      class ValidarFactura
        # Servicio de dominio que aplica reglas e invariantes previas a la creación de facturas.

        class ValidationError < StandardError; end

        Result = Struct.new(:cliente_id, :cliente, :monto, :fecha_emision, keyword_init: true)

        DEFAULT_CLIENTS = {
          '1' => { nombre: 'Cliente Demo', email: 'demo1@factumarket.test' },
          '123' => { nombre: 'Cliente Principal', email: 'principal@factumarket.test' }
        }.freeze

        def initialize(clientes: DEFAULT_CLIENTS)
          @clientes = normalizar_clientes(clientes)
        end

        def call(cliente_id:, monto:, fecha_emision:)
          cliente = validar_cliente(cliente_id)
          monto_vo = Facturas::Domain::ValueObjects::Monto.new(monto)
          fecha_vo = Facturas::Domain::ValueObjects::FechaEmision.new(fecha_emision)

          Result.new(
            cliente_id: cliente.id,
            cliente: cliente,
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

          datos = @clientes[id_normalizado]
          raise ValidationError, 'cliente_id no válido' unless datos

          Facturas::Domain::Entities::Cliente.new(id: id_normalizado, nombre: datos[:nombre], email: datos[:email])
        end

        def normalizar_clientes(clientes)
          clientes.transform_keys(&:to_s).transform_values do |valor|
            case valor
            when String
              { nombre: valor, email: generar_email(valor) }
            when Hash
              nombre = valor[:nombre] || valor['nombre']
              email = valor[:email] || valor['email'] || generar_email(nombre)
              { nombre: nombre, email: email }
            else
              raise ArgumentError, 'Formato de cliente inválido'
            end
          end
        end

        def generar_email(nombre)
          base = nombre.to_s.downcase.gsub(/\s+/, '.')
          "#{base}@factumarket.test"
        end
      end
    end
  end
end
