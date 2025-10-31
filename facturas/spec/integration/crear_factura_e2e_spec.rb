require 'spec_helper'

RSpec.describe 'Flujo completo de facturas', :integration do
  let(:controller) { Facturas::Interfaces::API.settings.facturas_controller }
  let(:use_case) { controller.instance_variable_get(:@crear_factura) }
  let(:dian_gateway) { use_case.instance_variable_get(:@dian_gateway) }
  let(:email_gateway) { use_case.instance_variable_get(:@correo_gateway) }

  before do
    stub_request(:post, %r{api\.mock-dian\.gov\.co/facturas}).to_return(status: 200, body: '{"status":"ok"}', headers: { 'Content-Type' => 'application/json' })
    stub_request(:post, %r{auditoria\.test:5003/eventos}).to_return(status: 201, body: '{}')
  end

  describe 'creación exitosa de una factura' do
    let(:payload) do
      {
        cliente_id: 1,
        monto: 45_000,
        fecha_emision: '2025-10-31'
      }
    end

    it 'persiste y notifica a todos los gateways' do
      expect(dian_gateway).to receive(:enviar_factura).and_call_original
      expect(email_gateway).to receive(:enviar_factura).and_call_original

      post '/facturas', JSON.generate(payload), 'CONTENT_TYPE' => 'application/json'

      expect(last_response.status).to eq(201)
      body = JSON.parse(last_response.body)
      expect(body).to include('id', 'cliente_id' => '1', 'monto' => 45_000.0, 'fecha_emision' => '2025-10-31')

      expect(a_request(:post, %r{auditoria\.test:5003/eventos})).to have_been_made.times(3)
    end
  end

  describe 'listado y consulta' do
    before do
      allow(dian_gateway).to receive(:enviar_factura).and_call_original
      allow(email_gateway).to receive(:enviar_factura).and_call_original
    end

    it 'devuelve las facturas creadas y permite recuperar por id' do
      ids = []
      3.times do |n|
        post '/facturas', JSON.generate(
          cliente_id: 1,
          monto: 1000 * (n + 1),
          fecha_emision: "2025-10-1#{n}"
        ), 'CONTENT_TYPE' => 'application/json'
        ids << JSON.parse(last_response.body)['id']
      end

      get '/facturas'
      expect(last_response.status).to eq(200)
      listado = JSON.parse(last_response.body)
      expect(listado.length).to eq(3)

      get "/facturas/#{ids.first}"
      expect(last_response.status).to eq(200)
      detalle = JSON.parse(last_response.body)
      expect(detalle['id']).to eq(ids.first)
      expect(detalle['cliente_id']).to eq('1')
    end
  end
end
