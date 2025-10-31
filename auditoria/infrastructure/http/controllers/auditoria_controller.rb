require_relative '../../../application/use_cases/registrar_evento'
require_relative '../../../application/use_cases/listar_eventos'
require_relative '../../../infrastructure/persistence/mongo_repository'

module Auditoria
  module Infrastructure
    module Http
      module Controllers
        class AuditoriaController
          # Controlador Infrastructure que orquesta casos de uso para registrar y consultar eventos.

          def initialize(repository: Auditoria::Infrastructure::Persistence::MongoRepository.new)
            @registrar_evento = Auditoria::Application::UseCases::RegistrarEvento.new(repository)
            @listar_eventos = Auditoria::Application::UseCases::ListarEventos.new(repository)
          end

          def health
            { status: 'ok', service: 'auditoria' }
          end

          def crear(payload)
            evento = @registrar_evento.call(payload)
            evento.to_h
          rescue ArgumentError => e
            { error: e.message }
          end

          def listar(entidad_id)
            @listar_eventos.call(entidad_id)
          rescue ArgumentError => e
            { error: e.message }
          end
        end
      end
    end
  end
end
