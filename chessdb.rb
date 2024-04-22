require './app/helpers/app_helper.rb'
require './lib/search.rb'
require 'sinatra'

class ChessDb < Sinatra::Base
  configure do
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET') {
      SecureRandom.hex(64)
    }
    set :root,  File.dirname(__FILE__)
    set :views, Proc.new { File.join(root, 'app', 'views') }
    helpers AppHelper
  end

  get '/' do
    haml :'search/search'
  end

  post '/' do
    start_date = parse_date(params['start_date'])
    end_date   = parse_date(params['end_date'])
    @results = Search.new.search(params['query'], params['fen'], start_date, end_date)
    haml :'search/results'
  end

  private

  def parse_date(date_str)
    date_str.empty? ? nil : Date.strptime(date_str, "%m/%d/%Y")
  end
end
