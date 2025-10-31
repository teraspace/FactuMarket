require 'active_record'

class AddDianColumnsToFacturas < ActiveRecord::Migration[7.1]
  def change
    add_column :facturas, :dian_status, :string
    add_column :facturas, :dian_uuid, :string
    add_column :facturas, :dian_response, :text
    add_column :facturas, :fecha_validacion_dian, :datetime

    add_index :facturas, :dian_uuid
  end
end
