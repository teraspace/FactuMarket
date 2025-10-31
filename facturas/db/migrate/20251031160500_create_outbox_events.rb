require 'active_record'
require 'securerandom'

class CreateOutboxEvents < ActiveRecord::Migration[7.1]
  def up
    return if table_exists?(:outbox_events)

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

  def down
    drop_table :outbox_events if table_exists?(:outbox_events)
  end
end
