require 'bigdecimal'
require 'bigdecimal/util'

module Facturas
  module Domain
    module ValueObjects
      class Monto
        # Value Object de Domain que asegura un importe positivo y normalizado.

        attr_reader :value

        def initialize(raw_value)
          @value = normalize(raw_value)
          validate_positive!
        end

        def to_decimal
          value
        end

        def to_f
          value.to_f
        end

        def to_s
          value.to_s('F')
        end

        private

        def normalize(raw_value)
          BigDecimal(raw_value.to_s)
        rescue ArgumentError
          raise ArgumentError, 'monto debe ser numérico'
        end

        def validate_positive!
          return if value > 0

          raise ArgumentError, 'monto debe ser mayor que cero'
        end
      end
    end
  end
end
