require 'spec_helper'

RSpec.describe 'Listado de eventos', :integration do
  it 'devuelve eventos por entidad ordenados por fecha' do
    client = Auditoria::Infrastructure::Persistence::DatabaseConfig.mongo_client
    collection = client[:events]

    collection.insert_one(servicio: 'facturas', entidad_id: 1, accion: 'CREAR', mensaje: 'Factura', timestamp: Time.now.utc.iso8601)
    collection.insert_one(servicio: 'facturas', entidad_id: 1, accion: 'NOTIFICAR', mensaje: 'Correo', timestamp: (Time.now.utc + 1).iso8601)

    get '/auditoria/1'

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body.length).to eq(2)
    expect(body.first['accion']).to eq('CREAR')
    expect(body.last['accion']).to eq('NOTIFICAR')
  end
end
