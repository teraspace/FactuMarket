require 'spec_helper'

RSpec.describe 'Registro de eventos', :integration do
  it 'guarda un evento y responde 201' do
    payload = {
      servicio: 'facturas',
      entidad_id: 1,
      accion: 'CREAR',
      mensaje: 'Factura creada exitosamente'
    }

    post '/events', JSON.generate(payload), { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(201)
    body = JSON.parse(last_response.body)
    expect(body).to include('status' => 'ok')

    client = Auditoria::Infrastructure::Persistence::DatabaseConfig.mongo_client
    expect(client[:events].count_documents({})).to eq(1)
  end
end
