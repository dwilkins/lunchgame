class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :edit, :update, :destroy ]
  after_action :check_next_round, except: [ :new ]

  def index
    @games = Game.all.order(created_at: :desc)
  end

  def show
  end

  def current
    @game = Game.current
    @game ? render(action: 'show') : redirect_to(new_game_path)
  end

  def new
    @game ||= Game.current
    if @game
      flash[:notice] = "A game for today already exists"
      Rails.logger.debug { "Redirecting to #{@game}" }
      redirect_to @game
    else
      @game = Game.new(required_voter_count: User.all.count)
      Rails.logger.debug { "New Game #{@game}" }
    end
  end


  def create
    Rails.logger.debug { "In Create" }
    @game = Game.current
    if @game
      flash[:notice] = "A game for today already exists"
      redirect_to @game
    else
      @game = Game.new(game_params)
      respond_to do |format|
        if @game.save
          format.html { redirect_to @game, notice: "#{@game.model_name.human} named \"#{@game.name}\" was successfully created." }
        else
          format.html { render action: 'new' }
        end
      end
    end
  end


  private

  def check_next_round
    if(@game)
      @game.update_round.save
    end
  end

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:required_voter_count, :number_of_selections)
  end
end
