require_relative 'database_config'

module Auditoria
  module Infrastructure
    module Persistence
      class MongoRepository
        # Repositorio Infrastructure que persiste eventos en la colección events de MongoDB.

        def initialize(collection: DatabaseConfig.mongo_client[:events])
          @collection = collection
        end

        def save(evento_hash)
          normalized = evento_hash.transform_keys(&:to_sym)
          normalized[:entidad_id] = normalized[:entidad_id].to_s
          @collection.insert_one(normalized)
        end

        def find_by_entidad_id(entidad_id)
          @collection
            .find(entidad_id: entidad_id.to_s)
            .sort(timestamp: 1)
            .map { |doc| document_to_hash(doc) }
        end

        private

        def document_to_hash(doc)
          hash = doc.to_h.transform_keys(&:to_s)
          hash.delete('_id')
          hash
        end
      end
    end
  end
end
