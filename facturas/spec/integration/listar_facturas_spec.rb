require 'spec_helper'
require 'date'

RSpec.describe 'Consulta de facturas', :integration do
  let(:auditoria_endpoint) { "#{ENV.fetch('AUDITORIA_URL')}/eventos" }

  before do
    WebMock.reset!
    stub_request(:post, auditoria_endpoint)
      .to_return(status: 201, body: '{}', headers: { 'Content-Type' => 'application/json' })
  end

  def crear_factura(cliente_id:, monto:, fecha_emision:)
    payload = {
      cliente_id: cliente_id,
      monto: monto,
      fecha_emision: fecha_emision
    }

    post '/facturas', JSON.generate(payload), 'CONTENT_TYPE' => 'application/json'
    JSON.parse(last_response.body)
  end

  it 'recupera una factura por identificador' do
    factura = crear_factura(cliente_id: '123', monto: 900, fecha_emision: (Date.today - 2).iso8601)
    expect(last_response.status).to eq(201)

    get "/facturas/#{factura['id']}"

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body).to include(
      'id' => factura['id'],
      'cliente_id' => '123',
      'monto' => 900.0,
      'fecha_emision' => factura['fecha_emision']
    )
  end

  it 'lista facturas dentro de un rango de fechas' do
    crear_factura(cliente_id: '123', monto: 100, fecha_emision: '2024-01-01')
    crear_factura(cliente_id: '1', monto: 200, fecha_emision: '2024-02-15')
    crear_factura(cliente_id: '123', monto: 300, fecha_emision: '2024-03-10')

    get '/facturas', { 'fechaInicio' => '2024-02-01', 'fechaFin' => '2024-03-01' }

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body.size).to eq(1)
    expect(body.first).to include(
      'cliente_id' => '1',
      'monto' => 200.0,
      'fecha_emision' => '2024-02-15'
    )
  end
end
