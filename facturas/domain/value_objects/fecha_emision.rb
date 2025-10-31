require 'date'

module Facturas
  module Domain
    module ValueObjects
      class FechaEmision
        # Value Object Domain que asegura fechas válidas y no posteriores al día actual.

        attr_reader :value

        def initialize(raw_value)
          @value = coerce_to_date(raw_value)
          validate_not_future!
        end

        def to_date
          value
        end

        def to_s
          value.iso8601
        end

        private

        def coerce_to_date(raw_value)
          case raw_value
          when Date
            raw_value
          else
            Date.parse(raw_value.to_s)
          end
        rescue ArgumentError
          raise ArgumentError, 'fecha_emision inválida'
        end

        def validate_not_future!
          return if value <= Date.today

          raise ArgumentError, 'fecha_emision no puede ser futura'
        end
      end
    end
  end
end
