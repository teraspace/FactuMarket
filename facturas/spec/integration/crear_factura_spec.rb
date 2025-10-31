require 'spec_helper'
require 'date'

RSpec.describe 'Creación de facturas', :integration do
  let(:auditoria_endpoint) { "#{ENV.fetch('AUDITORIA_URL')}/eventos" }

  before do
    WebMock.reset!
    stub_request(:post, auditoria_endpoint)
      .to_return(status: 201, body: '{}', headers: { 'Content-Type' => 'application/json' })
  end

  it 'crea una factura válida, persiste y envía evento de auditoría' do
    payload = {
      cliente_id: '123',
      monto: 4500,
      fecha_emision: (Date.today - 1).iso8601
    }

    post '/facturas', JSON.generate(payload), 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(201)
    expect(last_response.headers['Location']).to match(%r{\A/facturas/})

    body = JSON.parse(last_response.body)
    expect(body).to include(
      'cliente_id' => '123',
      'monto' => 4500.0,
      'fecha_emision' => payload[:fecha_emision]
    )
    expect(body['id']).not_to be_nil

    record = Facturas::Infrastructure::Persistence::FacturaRecord.find(body['id'])
    expect(record.cliente_id).to eq('123')
    expect(record.monto).to eq(4500.0)

    expect(a_request(:post, auditoria_endpoint)).to have_been_made.times(3)
    expect(WebMock).to have_requested(:post, auditoria_endpoint)
      .with(body: hash_including('accion' => 'CREAR')).once
    expect(WebMock).to have_requested(:post, auditoria_endpoint)
      .with(body: hash_including('accion' => 'NOTIFICAR')).once
    expect(WebMock).to have_requested(:post, auditoria_endpoint)
      .with(body: hash_including('accion' => 'VALIDAR')).once
  end

  it 'rechaza creación con monto inválido' do
    payload = {
      cliente_id: '123',
      monto: 0,
      fecha_emision: Date.today.iso8601
    }

    post '/facturas', JSON.generate(payload), 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    body = JSON.parse(last_response.body)
    expect(body['error']).to match(/mayor que cero/i)

    expect(Facturas::Infrastructure::Persistence::FacturaRecord.count).to eq(0)
    expect(a_request(:post, auditoria_endpoint)).not_to have_been_made
  end

end
