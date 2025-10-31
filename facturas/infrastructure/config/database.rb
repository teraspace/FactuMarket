require 'active_record'
require 'logger'
require 'fileutils'

module Facturas
  module Infrastructure
    module Config
      class Database
        # Configuración de acceso a datos en Infrastructure; conecta con Oracle o SQLite.

        class << self
          def establish_connection
            return if ActiveRecord::Base.connected?

            if ActiveRecord.respond_to?(:default_timezone=)
              ActiveRecord.default_timezone = :utc
            elsif ActiveRecord::Base.respond_to?(:default_timezone=)
              ActiveRecord::Base.default_timezone = :utc
            end

            config = oracle_available? ? oracle_config : sqlite_config

            ActiveRecord::Base.establish_connection(config)
            ActiveRecord::Base.logger = Logger.new($stdout) if ENV['AR_LOGGER'] == 'true'

            ensure_schema!
          end

          private

          def oracle_available?
            return false unless ENV.fetch('USE_ORACLE', 'false').casecmp('true').zero?

            require 'active_record/connection_adapters/oracle_enhanced_adapter'
            true
          rescue LoadError
            warn '[database] Oracle Enhanced adapter no disponible, se usará SQLite como fallback'
            false
          end

          def oracle_config
            {
              adapter: 'oracle_enhanced',
              host: ENV.fetch('ORACLE_HOST', 'oracle-db'),
              port: ENV.fetch('ORACLE_PORT', 1521),
              database: ENV.fetch('ORACLE_SERVICE_NAME', 'FREEPDB1'),
              username: ENV.fetch('ORACLE_USER', 'system'),
              password: ENV.fetch('ORACLE_PASSWORD', 'Oracle123')
            }
          end

          def sqlite_config
            {
              adapter: 'sqlite3',
              database: sqlite_database_path
            }
          end

          def sqlite_database_path
            path = ENV.fetch('SQLITE_PATH', File.expand_path('../../db/facturas.sqlite3', __dir__))
            FileUtils.mkdir_p(File.dirname(path))
            path
          end

          def ensure_schema!
            ActiveRecord::Schema.define do
              unless ActiveRecord::Base.connection.data_source_exists?(:facturas)
                create_table :facturas, id: :string, primary_key: :id do |t|
                  t.string  :cliente_id, null: false
                  t.decimal :monto, precision: 15, scale: 2, null: false
                  t.date    :fecha_emision, null: false
                  t.string  :dian_status
                  t.string  :dian_uuid
                  t.text    :dian_response
                  t.datetime :fecha_validacion_dian
                  t.timestamps precision: 6, null: false
                end

                add_index :facturas, :fecha_emision
                add_index :facturas, :dian_uuid
              end

              unless ActiveRecord::Base.connection.data_source_exists?(:outbox_events)
                create_table :outbox_events, id: :string, primary_key: :id do |t|
                  t.string :event_type, null: false
                  t.string :entity_id, null: false
                  t.text   :payload, null: false
                  t.string :status, null: false, default: 'pending'
                  t.datetime :created_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
                  t.datetime :processed_at
                end

                add_index :outbox_events, :status
                add_index :outbox_events, :entity_id
              end
            end

            add_column_unless_exists(:facturas, :dian_status, :string)
            add_column_unless_exists(:facturas, :dian_uuid, :string)
            add_column_unless_exists(:facturas, :dian_response, :text)
            add_column_unless_exists(:facturas, :fecha_validacion_dian, :datetime)
            add_index_unless_exists(:facturas, :dian_uuid)
          end

          def add_column_unless_exists(table, column, type)
            return if ActiveRecord::Base.connection.column_exists?(table, column)

            ActiveRecord::Base.connection.add_column(table, column, type)
          end

          def add_index_unless_exists(table, column)
            return if ActiveRecord::Base.connection.index_exists?(table, column)

            ActiveRecord::Base.connection.add_index(table, column)
          end
        end
      end
    end
  end
end
