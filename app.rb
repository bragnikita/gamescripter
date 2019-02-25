require 'dotenv/load'

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'

require './lib/initializers'

# $LOAD_PATH << File.expand_path('lib', __dir__)
require './lib/database'
require './lib/categories_service'
require './lib/services'
require './lib/errors'
require './lib/utils'

configure do
  mime_type :json, 'application/json'
  mime_type :html, 'application/html'
end

configure :development do
  set :static => true
  set :public_folder => File.expand_path('public', __dir__)
end

class App < Sinatra::Application
  include ApiHelpers

  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'reloaded'
    end
  end
  # register Sinatra::Namespace

  def initialize
    super
  end

  # ------ Filters ------

  before %r{\/((?!auth\/create).)*} do
    authenticate
  end

  get '/' do
    content_type :html
    File.read(File.join('public', 'index.html'))
  end

  # -------- Categories ---------
  #
  get '/category/:id/parents' do |id|
    json categories.get_parents id
  end

  get '/category/:id' do |id|
    json categories.get(id)
  end

  get '/categories/root' do
    json categories.root
  end

  get '/categories' do
    json categories.all
  end

  put '/categories' do
    data = parse_body
    json categories.create(data)
  end

  delete '/category/:id' do |id|
    res = categories.delete(id)
    [422, 'Category has scripts under it and can not be deleted'] unless res
    content_type :json
    200
  end

  post '/category/:id' do
    data = parse_body
    # data[:key] = params[:id]
    categories.update(params[:id], data)
    200
  end

  # -------- Users ---------

  post '/users' do
    data = parse_body
    json users.create(data)
  end

  put '/users/:id/meta' do
    data = parse_body
    users.change_meta(params[:id], data)
    200
  end

  put '/users/:id/status' do
    data = parse_body
    users.change_status(params[:id], data)
    200
  end

  get '/users/:id' do
    json users.show(params[:id])
  end

  get '/users' do
    json users.list(params[:filter], params[:sort])
  end

  delete '/users/:id' do
    users.delete(params[:id])
    200
  end

  # -------- Authorization -----

  post '/auth/create' do
    token = auth.signin parse_body
    json token: token
  end

  # -------- Permissions -----


  # -------- Scripts ------

  get '/script/:id' do |id|

  end

  post '/scripts' do

  end

  put '/script/:id' do |id|

  end

  put '/script/:id/content/save' do |id|

  end

  put '/script/:id/content/update' do |id|

  end

  get '/script/:id/preview' do |id|

  end

  post '/script/:id/images' do

  end

  get '/script/:id/images' do

  end

  # -------- Errors ------

  error 404 do
    [404, 'Route not found']
  end

  error ObjectNotFound do
    [404, env['sinatra.error'].message]
  end

  error Mongoid::Errors::MongoidError do
    err = env['sinatra.error']
    if err.kind_of?(Mongoid::Errors::DocumentNotFound)
      ret = [404, env['sinatra.error'].message]
    else
      ret = [422, env['sinatra.error'].message]
    end
    ret
  end

  error BadRequest do
    [422, env['sinatra.error'].message]
  end

  error JWT::DecodeError do
    error = env['sinatra.error']
    if error.is_a? JWT::ExpiredSignature
      [401, 'Token expired']
    else
      [422, error.message]
    end
  end

  # ---------- Helpers ------
  def categories
    CategoriesService.new
  end

  def users
    UsersService.new({ username: 'admin' })
  end

  def auth
    AuthService.new
  end

  def authenticate
    test_username = ENV['TESTING_AUTH_USER_NAME']
    if settings.test? && !test_username.nil?
      @user = User.find_by(username: test_username)
    else
      auth_headers = request_headers['authorization']
      if auth_headers.nil?
        raise AuthError, 'Not authorized'
      end

      token = auth_headers.split.last
      @user = auth.authenticate token
    end
    if @user.nil?
      raise AuthError, 'Not authenticated'
    end
  end

  run! if app_file == $PROGRAM_NAME
end