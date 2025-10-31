require 'active_record'
require 'securerandom'

module Facturas
  module Infrastructure
    module Persistence
      class FacturaRecord < ActiveRecord::Base
        # Modelo ActiveRecord en Infrastructure para mapear la tabla facturas.

        self.table_name = 'facturas'
        self.primary_key = 'id'
        self.inheritance_column = :_type_disabled

        before_create { self.id ||= SecureRandom.uuid }

        scope :with_fecha_inicio, ->(fecha) { where(arel_table[:fecha_emision].gteq(fecha)) if fecha }
        scope :with_fecha_fin, ->(fecha) { where(arel_table[:fecha_emision].lteq(fecha)) if fecha }
      end
    end
  end
end
