require 'spec_helper'

RSpec.describe 'Health endpoint', :integration do
  it 'returns ok status' do
    get '/health'

    expect(last_response.status).to eq(200)
    body = JSON.parse(last_response.body)
    expect(body).to include('status' => 'ok', 'service' => 'auditoria')
  end
end
