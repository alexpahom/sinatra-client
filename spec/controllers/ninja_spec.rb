require_relative '../spec_helper'
require_relative '../../app'

describe Application do

  def app
    Application
  end

  before do
    # Do nothing
  end

  after do
    # Do nothing
  end

  context 'when condition' do
    it 'gets all the tasks', :vcr, type: :controller do
      get '/'
      expect(last_response.status).to eq 200
    end

    it 'creates new task', :vcr, type: :controller do
      post '/create', { title: 'New task', status: :open }.to_json
      expect(last_response.status).to eq 201
    end
  end
end