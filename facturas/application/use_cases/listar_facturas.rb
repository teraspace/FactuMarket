require 'date'

module Facturas
  module Application
    module UseCases
      class ListarFacturas
        # Caso de uso Application que recupera facturas filtradas por periodo.

        def initialize(repository:)
          @repository = repository
        end

        def call(fecha_inicio: nil, fecha_fin: nil)
          inicio = parse_date(fecha_inicio)
          fin = parse_date(fecha_fin)
          validate_range!(inicio, fin)

          @repository.all_by_date_range(inicio, fin)
        end

        private

        def parse_date(value)
          return nil if value.nil? || value.to_s.strip.empty?

          Date.parse(value.to_s)
        rescue ArgumentError
          raise ArgumentError, 'fecha inválida'
        end

        def validate_range!(inicio, fin)
          return unless inicio && fin && inicio > fin

          raise ArgumentError, 'fechaInicio no puede ser posterior a fechaFin'
        end
      end
    end
  end
end
