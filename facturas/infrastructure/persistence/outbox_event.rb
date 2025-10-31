require 'active_record'
require 'securerandom'

module Facturas
  module Infrastructure
    module Persistence
      class OutboxEvent < ActiveRecord::Base
        self.table_name = 'outbox_events'
        self.primary_key = 'id'
        self.inheritance_column = :_type_disabled

        before_create { self.id ||= SecureRandom.uuid }

        enum status: {
          pending: 'pending',
          processed: 'processed',
          failed: 'failed'
        }
      end
    end
  end
end
