require 'active_support/all'
require 'sinatra'
require 'rack-flash'
require_relative 'game'
require_relative 'player'
require_relative 'board'
require_relative 'cell'
require_relative 'ship'
require_relative 'fleet'

class BattleShips < Sinatra::Base

  def switch_players
    session[:current_player] = GAME.opponent_name(session[:current_player])
  end

  # set :views, Proc.new { File.join(root, "..", "views") }
  enable :sessions
  use Rack::Flash
  use Rack::MethodOverride
  
  GAME = Game.new

  get '/' do
    if session[:current_player]
      @current_player = session[:current_player]
    end
    session[:game_in_progress], session[:placing_ships] = false
    erb :index
  end

  get '/new_game' do
    GAME.fleets.clear
    GAME.players.clear
    redirect to('/')
  end

  get '/register' do
    session[:placing_ships] = false
    erb :player_reg_form      
  end

  post '/register' do
    GAME.add_player(params[:player_name])
    session[:current_player] = params[:player_name]
    flash[:notice] = 'Thanks for registering, you can know place your ships'
    redirect to('/get_coordinates')
  end

  get '/switch_players' do
      switch_players
      erb :index
  end


  get '/get_coordinates' do
      session[:placing_ships] = true
      if GAME.fleet_empty_for(session[:current_player])
        erb :all_fleet_ships_placed
      else
      @ship = GAME.ship_to_place(session[:current_player])
      @ship_type = @ship.type.to_s.titleize
      @ship_size = @ship.size
      erb :get_coordinates
      end
  end

  get '/place_ship' do
      start_cell = params[:column]+params[:row]
      orientation = params[:orientation]
      player = GAME.which_is(session[:current_player])
      ship = GAME.ship_to_place(session[:current_player])
      begin
        player.board.place(ship, start_cell, orientation)
        GAME.remove_placed_ship_from_fleet(session[:current_player]) 
      rescue => error
        flash[:notice] = error.to_s
      end
      redirect '/get_coordinates'
  end

  get '/ready_to_play' do
    session[:placing_ships] = false
    switch_players
    redirect to('/take_shot')
  end

  get '/take_shot' do
    session[:grid_display] = true
    erb :take_shot
  end

  get '/take_shot_interstitial' do
    erb :take_shot_interstitial
  end

  get '/shot_result' do
    @target_cell = params[:column]+params[:row]
    begin
      GAME.opponent_object(session[:current_player]).board.shoot_at(@target_cell)
    rescue => error
      flash[:notice] = error.to_s
      redirect '/take_shot'
    end
    erb :shot_result
  end

  get '/shot_result' do
    erb :shot_result
  end

  get '/next_player_turn' do
    switch_players
    session[:grid_display] = false
    redirect '/take_shot_interstitial'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
