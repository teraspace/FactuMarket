require 'active_record'
require 'securerandom'

class CreateFacturasUuid < ActiveRecord::Migration[7.1]
  def up
    return if table_exists?(:facturas)

    create_table :facturas, id: :string, primary_key: :id do |t|
      t.string  :cliente_id, null: false
      t.decimal :monto, precision: 15, scale: 2, null: false
      t.date    :fecha_emision, null: false
      t.timestamps precision: 6, null: false
    end

    add_index :facturas, :fecha_emision
  end

  def down
    drop_table :facturas if table_exists?(:facturas)
  end
end
