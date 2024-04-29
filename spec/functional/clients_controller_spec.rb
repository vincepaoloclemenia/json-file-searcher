require 'rails_helper'

RSpec.describe ClientsController, type: :request do
  let(:parameters) { nil }
  let(:body) { JSON.parse(response.body) }
  before { get root_path, params: parameters }
  
  context 'when parameters is nil' do
    it 'returns all the clients list' do
      expect(body).to eq([])
    end
  end

  context 'when parameter specified has a query key indicated but no key' do
    let(:parameters) { { query: 'sample' } }

    it 'returns unprocessable entity error' do
      expect(body).to eq({ 'error' => 'Query must have keys'} )
    end
  end

  context 'when parameter query key specified is unknown' do
    let(:parameters) { { query: { unknown_key: 'sample'} } }

    it 'returns unprocessable entity error' do
      expect(body).to eq({ 'error' => 'Missing query keys: (full_name, email)'} )
    end
  end

  context 'when parameters specified is valid ' do
    let(:parameters) { { query: { full_name: 'jane' } } }

    it 'returns list of clients that match the given query' do
      expect(body).to eq([{"email"=>"jane.smith@yahoo.com", "full_name"=>"Jane Smith", "id"=>2}, {"email"=>"jane.smith@yahoo.com", "full_name"=>"Another Jane Smith", "id"=>15}])
    end
  end

  context 'when requsting for duplicates' do
    let(:parameters) { { query: { full_name: 'jane' }, find_duplicates: true } }

    it 'returns list of clients that match the given query' do
      expect(body['duplicates']).to eq({"jane.smith@yahoo.com" => [{"email"=>"jane.smith@yahoo.com", "full_name"=>"Jane Smith", "id"=>2}, {"email"=>"jane.smith@yahoo.com", "full_name"=>"Another Jane Smith", "id"=>15}]})
    end
  end
end