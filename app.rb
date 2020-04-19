require 'sinatra'
require 'httparty'
require 'pry'
API_HOST = 'http://localhost:4568'

helpers do
  def alert_class_for(flash_type)
    {
        success: 'alert-success',
        error: 'alert-danger',
        alert: 'alert-warning',
        notice: 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end

  def json_params
    begin
      JSON.parse(request.body.read)
    rescue
      halt 400, { message:'Invalid JSON' }.to_json
    end
  end
end

get '/' do
  response = HTTParty.get("#{API_HOST}/api/v1/todos")
  if response.success?
    @tasks = JSON.parse response.body
  else
    status response.code
  end
  erb :index
end

post '/create' do
  params = json_params
  payload = {
      title: params['title'],
      description: params['description'],
      status: params['status'],
      rank: params['rank']
  }.to_json
  response = HTTParty.post("#{API_HOST}/api/v1/todos", body: payload)
  if response.success?
    status 201
    body response.body
  else
    status response.code
    body response['message']
  end
end

put '/update/:id' do |id|
  params = json_params
  payload = {
      title: params['title'],
      description: params['description'],
      status: params['status'],
      rank: params['rank']
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
