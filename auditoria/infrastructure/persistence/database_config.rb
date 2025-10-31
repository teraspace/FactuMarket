require 'mongo'

module Auditoria
  module Infrastructure
    module Persistence
      class DatabaseConfig
        # Configuración Infrastructure responsable de inicializar el cliente de MongoDB.

        def self.mongo_client
          @mongo_client ||= Mongo::Client.new(ENV.fetch('MONGO_URI', 'mongodb://mongo-db:27017/auditoria'))
        end
      end
    end
  end
end
