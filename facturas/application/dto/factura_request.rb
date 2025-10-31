module Facturas
  module Application
    module DTO
      class FacturaRequest
        # DTO de Application que encapsula datos de entrada para casos de uso de facturas.

        attr_reader :cliente_id, :monto, :fecha_emision

        def initialize(cliente_id:, monto:, fecha_emision:)
          @cliente_id = cliente_id
          @monto = monto
          @fecha_emision = fecha_emision
        end

        def self.from_hash(payload)
          symbolized = symbolize_keys(payload)
          new(
            cliente_id: symbolized.fetch(:cliente_id),
            monto: symbolized.fetch(:monto),
            fecha_emision: symbolized.fetch(:fecha_emision)
          )
        rescue KeyError => e
          raise ArgumentError, "campo requerido faltante: #{e.key}"
        end

        def to_h
          {
            cliente_id: cliente_id,
            monto: monto,
            fecha_emision: fecha_emision
          }
        end

        def self.symbolize_keys(payload)
          payload.each_with_object({}) do |(key, value), memo|
            memo[key.to_sym] = value
          end
        end
        private_class_method :symbolize_keys
      end
    end
  end
end
