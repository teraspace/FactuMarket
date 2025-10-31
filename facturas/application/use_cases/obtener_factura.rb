module Facturas
  module Application
    module UseCases
      class ObtenerFactura
        # Caso de uso Application que recupera una factura existente desde el repositorio.

        def initialize(repository:)
          @repository = repository
        end

        def call(id:)
          normalized_id = id.to_s.strip
          raise ArgumentError, 'id requerido' if normalized_id.empty?

          @repository.find_by_id(normalized_id)
        end
      end
    end
  end
end
