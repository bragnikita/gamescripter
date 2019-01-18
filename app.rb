require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'

# $LOAD_PATH << File.expand_path('lib', __dir__)
require './lib/database'
require './lib/categories_service'
require './lib/errors'

configure do
  mime_type :json, 'application/json'
  mime_type :html, 'application/html'

end
configure :development do
  set :static => true
  set :public_folder => File.expand_path('public', __dir__)
end

class App < Sinatra::Application
  register Sinatra::Namespace

  def initialize
    super
    Database.instance.connect
  end

  get '/' do
    content_type :html
    File.read(File.join('public', 'index.html'))
  end

  namespace '/api' do

    # -------- Categories ---------
    get '/category/:id' do
      json categories.get(params[:id])
    end

    get '/categories' do
      json categories.all
    end

    put '/categories' do
      data = parse_body
      json categories.create(data)
    end

    delete '/category/:id' do
      res = categories.delete(params[:id])
      [422, 'Category has scripts under it and can not be deleted'] unless res
      content_type :json
      200
    end

    post '/category/:id' do
      data = parse_body
      data[:key] = params[:id]
      json categories.update(data)
    end

    # -------- Scripts ---------

  end


  error ObjectNotFound do
    [404, env['sinatra.error'].message]
  end

  error BadRequest do
    [422, env['sinatra.error'].message]
  end

  def categories
    CategoriesService.new
  end

  def parse_body
    request.body.rewind
    JSON.parse(request.body.read, symbolize_names: true)
  end

  run! if app_file == $PROGRAM_NAME
end