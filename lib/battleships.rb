require 'active_support/all'
require 'sinatra'
require_relative 'player'
require_relative 'fleet'

class BattleShips < Sinatra::Base

  set :views, Proc.new { File.join(root, "..", "views") }
  enable :sessions

  get '/' do
    erb :index
  end

  get '/new_game' do
    erb :player1  
  end

  post '/registered1' do
    session[:player_name1] = params[:player_name]
    if session[:player_name1].empty?
      erb :player1
    else
      session[:player_name1] = Player.new(params[:player_name])
      player = session[:player_name1]
      session[:fleet1] = player.fleet.ship_array
      erb :player2
    end
  end

  # get '/new_game' do
    #   session[:players] = []
    #   session[:fleets] = []
    #   erb :player_reg_form
    # end

  # post '/registered' do
    # if params[:player_name].empty?
      # erb :player_reg_form
    # else
      # player = Player.new(params[:player_name])
      # session[:players] << player
      # session[:fleets] << player.fleet.ship_array
      # if session[:players].size ==2
        # move on to placing ships for 1st player
      # else
        # erb :player_reg_form
      # end
    # end
  # end

  post '/registered2' do
    session[:player_name2] = params[:player_name]
    if session[:player_name2].empty?
      erb :player2
    else
      session[:player_name2] = Player.new(params[:player_name])
      erb :register_complete 
    end
  end

  get '/set_up/?:error?' do
    if session[:fleet1].size > 0
      session[:ship1] = session[:fleet1].shift
      @ship1 = session[:ship1]
      @error = params[:error]
      erb :set_up, locals: {ship: @ship1, error: @error}
    else
      "You have placed all your ships"
    end
  end

  get '/place_ship' do
    if params
      start_cell = params[:start_cell]
      orientation = params[:orientation]
      player = session[:player_name1]
      ship = session[:ship1]
      begin
        player.board.place_ship(ship, start_cell.to_sym, orientation.to_sym)
        redirect '/set_up' # erb :place_success
      rescue RuntimeError
        erb :place_error
      end
    end
  end



  # start the server if ruby file executed directly
  run! if app_file == $0
end
