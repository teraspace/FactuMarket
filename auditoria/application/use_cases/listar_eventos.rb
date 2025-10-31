module Auditoria
  module Application
    module UseCases
      class ListarEventos
        # Caso de uso Application que consulta eventos en base al identificador de entidad.

        def initialize(repository)
          @repository = repository
        end

        def call(entidad_id)
          raise ArgumentError, 'entidad_id requerido' if entidad_id.nil? || entidad_id.to_s.strip.empty?

          @repository.find_by_entidad_id(entidad_id)
        end
      end
    end
  end
end
