require 'rails_helper'

RSpec.describe JsonSearcherService do
  let(:term) { 'Jane' }
  let(:attribute) { :full_name }
  let(:find_duplicates) { false }

  context 'when inputs are invalid' do
    context 'when invalid file' do
      it 'raises error' do
        expect { described_class.new(path: 'public/clients.txt', query: { attribute => '' }, find_duplicates:).call }.to raise_error(RuntimeError, "File is not a json 'text/plain'")
      end
    end

    context 'when invalid query' do
      context 'when attribute passed is unknown' do
        it 'raises error' do
          expect { described_class.new(path: 'public/clients.json', query: { unknown_attribute: 'sample' }, find_duplicates:).call }.to raise_error(StandardError, 'Invalid query attributes')
        end
      end

      context 'when query is empty' do
        it 'raises error' do
          expect { described_class.new(path: 'public/clients.json', query: {}, find_duplicates:).call }.to raise_error(StandardError, 'Query is empty')
        end
      end
    end
  end

  context 'when searching by full_name' do
    it 'returns the list accurately' do
      expect(described_class.new(path: 'public/clients.json', query: { attribute => term }, find_duplicates: ).call).to eq(
        [
          {email: 'jane.smith@yahoo.com', full_name: 'Jane Smith', id: 2},
          {email: 'jane.smith@yahoo.com', full_name: 'Another Jane Smith', id: 15}
        ]
      )
    end

    context 'when attribute used is email' do
      let(:attribute) { :email }

      it 'returns the list accurately' do
        expect(described_class.new(path: 'public/clients.json', query: { attribute => term }, find_duplicates:).call).to eq(
          [
            {email: 'jane.smith@yahoo.com', full_name: 'Jane Smith', id: 2},
            {email: 'jane.smith@yahoo.com', full_name: 'Another Jane Smith', id: 15}
          ]
        )
      end
    end

    context 'when getting the duplicates' do
      let(:find_duplicates) { true }

      it 'returns the clients that match the term specified and the duplicates by email' do
        expect(described_class.new(path: 'public/clients.json', query: { attribute => term }, find_duplicates:).call).to eq(
          { 
            duplicates: {
              'jane.smith@yahoo.com' => [
                {email: 'jane.smith@yahoo.com', full_name: 'Jane Smith', id: 2},
                {email: 'jane.smith@yahoo.com', full_name: 'Another Jane Smith', id: 15}
              ]
            },
            term_matches: [
              {email: 'jane.smith@yahoo.com', full_name: 'Jane Smith', id: 2},
              {email: 'jane.smith@yahoo.com', full_name: 'Another Jane Smith', id: 15}
            ]
          }
        )
      end
    end
  end
end