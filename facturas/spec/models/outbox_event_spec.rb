require 'spec_helper'

RSpec.describe Facturas::Infrastructure::Persistence::OutboxEvent do
  it 'genera un uuid y queda pendiente por defecto' do
    event = described_class.create!(
      event_type: 'FacturaCreada',
      entity_id: '123',
      payload: { foo: 'bar' }.to_json
    )

    expect(event.id).to be_a(String)
    expect(event.id.length).to be >= 32
    expect(event).to be_pending
    expect(event.payload).to include('foo')
  end
end
