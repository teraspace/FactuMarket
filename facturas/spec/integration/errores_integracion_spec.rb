require 'spec_helper'

RSpec.describe 'Manejo de errores e integraciones externas', :integration do
  let(:controller) { Facturas::Interfaces::API.settings.facturas_controller }
  let(:use_case) { controller.instance_variable_get(:@crear_factura) }
  let(:dian_gateway) { use_case.instance_variable_get(:@dian_gateway) }
  let(:email_gateway) { use_case.instance_variable_get(:@correo_gateway) }

  before do
    stub_request(:post, %r{auditoria\.test:5003/eventos}).to_return(status: 201, body: '{}')
  end

  it 'rechaza facturas con monto inválido' do
    post '/facturas', JSON.generate(cliente_id: 1, monto: -100, fecha_emision: '2025-10-31'), 'CONTENT_TYPE' => 'application/json'

    expect(last_response.status).to eq(422)
    expect(JSON.parse(last_response.body)['error']).to match(/mayor que cero/i)
    expect(Facturas::Infrastructure::Persistence::FacturaRecord.count).to eq(0)
    expect(a_request(:post, %r{auditoria\.test:5003/eventos})).not_to have_been_made
  end

  it 'registra warning cuando la DIAN falla pero continúa el flujo' do
    allow(dian_gateway).to receive(:enviar_factura).and_raise(StandardError, 'Servicio DIAN no disponible')
    allow(email_gateway).to receive(:enviar_factura).and_call_original

    expect do
      post '/facturas', JSON.generate(cliente_id: 1, monto: 1000, fecha_emision: '2025-10-31'), 'CONTENT_TYPE' => 'application/json'
    end.to output(/Fallo al enviar a DIAN/).to_stderr

    expect(last_response.status).to eq(201)
    expect(a_request(:post, %r{auditoria\.test:5003/eventos})).to have_been_made.at_least_twice
  end

  it 'registra warning cuando el correo falla y mantiene la respuesta 201' do
    allow(dian_gateway).to receive(:enviar_factura).and_call_original
    allow(email_gateway).to receive(:enviar_factura).and_raise(StandardError, 'SMTP error')

    expect do
      post '/facturas', JSON.generate(cliente_id: 1, monto: 2000, fecha_emision: '2025-10-31'), 'CONTENT_TYPE' => 'application/json'
    end.to output(/Fallo al enviar correo/).to_stderr

    expect(last_response.status).to eq(201)
    expect(a_request(:post, %r{auditoria\.test:5003/eventos})).to have_been_made.at_least_twice
  end
end
