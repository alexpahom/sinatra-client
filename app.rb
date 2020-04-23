require 'sinatra'
require 'httparty'
require 'pry'
require 'sinatra/flash'

API_HOST = 'http://localhost:4568'
enable :sessions

helpers do
  JS_ESCAPE_MAP = {
      '\\'    => '\\\\',
      "</"    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',
      "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'"
  }

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

  def escape_javascript(javascript)
    javascript = javascript.to_s
    if javascript.empty?
      ""
    else
      javascript.gsub(/(\\|<\/|\r\n|\342\200\250|\342\200\251|[\n\r"'])/u) { |match| JS_ESCAPE_MAP[match] }
    end
  end
  alias_method :j, :escape_javascript
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
  @task = JSON.parse(response.body)
  if response.success?
    status 201
    flash.now[:success] = 'Task Created!'
  else
    status response.code
    flash.now[:error] = response['message']
  end
  content_type 'text/javascript'
  erb :'create.js'
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
  @task_id = id
  response = HTTParty.delete("#{API_HOST}/api/v1/todos/#{id}")
  if response.success?
    status 200
    flash.now[:success] = 'Deleted'
  else
    status response.status
    flash.now[:error] = response.message
  end
  content_type 'text/javascript'
  erb :'delete.js'
end
