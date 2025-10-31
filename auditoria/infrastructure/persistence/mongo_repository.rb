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
          @collection.insert_one(evento_hash)
        end

        def find_by_entidad_id(entidad_id)
          @collection
            .find(entidad_id: entidad_id)
            .sort(timestamp: 1)
            .map { |doc| document_to_hash(doc) }
        end

        private

        def document_to_hash(doc)
          doc.transform_keys!(&:to_s)
          doc.delete('_id')
          doc
        end
      end
    end
  end
end
