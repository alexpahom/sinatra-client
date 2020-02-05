require 'sinatra'
require 'httparty'
require 'pry'
API_HOST = 'http://localhost:4568'

get '/' do
  response = HTTParty.get("#{API_HOST}/api/v1/todos")
  @tasks = {
      open: [],
      progress: [],
      close: []
  }
  if response.success?
    # TODO: refactor
    parsed_records = JSON.parse response.body
    %w(open progress close).each do |status|
      parsed_records.each do |task|
        @tasks[status.to_sym] << task if task['status'] == status
      end
    end
  else
    status response.code
  end
  erb :index
end

post '/create' do
  payload = {
      title: params[:title],
      description: params[:description],
      status: params[:status],
      rank: params[:rank]
  }
  response = HTTParty.post("#{API_HOST}/api/v1/todos", body: payload)
  if response.success?
    status 201
  else
    status response.status
    body response.message
  end
end

put '/update/:id' do |id|
  payload = {
      title: params[:title],
      description: params[:description],
      status: params[:status],
      rank: params[:rank]
  }
  response = HTTParty.put("#{API_HOST}/api/v1/todos/#{id}", body: payload)
  if response.success?
    status 200
  else
    status response.status
    body response.message
  end
end

delete '/update/:id' do |id|
  response = HTTParty.delete("#{API_HOST}/api/v1/todos/#{id}")
  if response.success?
    status 204
  else
    status response.status
    body response.message
  end
end
