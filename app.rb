require 'compass'
require 'sinatra/base'
require 'haml'
require 'httparty'
require 'pry'
require 'sinatra/flash'

API_HOST = 'http://localhost:4568'

class Application < Sinatra::Base

  enable :sessions
  register Sinatra::Flash

  configure do
    Compass.add_project_configuration("#{File.expand_path('.')}/compass.config")
  end

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

    def parse_json(params = request.body.read)
      JSON.parse(params)
    rescue
      halt 400, { message: 'Invalid JSON format' }.to_json
    end

    def build_payload(params)
      {
          title: params['title'],
          description: params['description'],
          status: params['status'],
          rank: params['rank']
      }.select { |_k, v| v }
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

  get '/css/:name.css' do
    content_type 'text/css'
    sass :"#{params[:name]}"
  end

  get '/' do
    response = HTTParty.get("#{API_HOST}/api/v1/todos")
    if response.success?
      @tasks = parse_json(response.body)
    else
      status response.code
    end
    haml :index
  end

  post '/create' do
    payload = build_payload(parse_json)
    response = HTTParty.post("#{API_HOST}/api/v1/todos", body: payload.to_json)
    @task = parse_json(response.body)
    if(@result = response.success?)
      status 201
      flash.now[:success] = 'Task Created!'
    else
      status 200
      flash.now[:error] = response.first
    end
    content_type 'text/javascript'
    erb :'create.js'
  end

  patch '/update/:id' do |id|
    payload = build_payload(parse_json)
    response = HTTParty.patch("#{API_HOST}/api/v1/todos/#{id}", body: payload.to_json)
    if(@result = response.success?)
      status 200
      unless payload[:status]
        @task = parse_json(response.body)
        flash.now[:success] = 'Saved'
      end
    else
      status response.status
      flash.now[:error] = response.first
    end
    content_type 'text/javascript'
    erb :'update.js'
  end

  delete '/update/:id' do |id|
    @task_id = id
    response = HTTParty.delete("#{API_HOST}/api/v1/todos/#{id}")
    if(@result = response.success?)
      flash.now[:success] = 'Deleted'
    else
      flash.now[:error] = response.first
    end
    status 200
    content_type 'text/javascript'
    erb :'delete.js'
  end

  run!
end