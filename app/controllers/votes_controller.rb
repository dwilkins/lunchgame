class VotesController < ApplicationController
  before_action :set_game_and_round, only: [:create]

  def create
    @game ||= Game.current
    if(@game && @round == @game.round)
      new_votes = Vote.factory(current_user, @game,params[:restaurant][:name])
      num_votes = new_votes.count
      redirect_to @game, notice: "Created #{num_votes} new vote".pluralize(num_votes)
    else
      redirect_to @game, alert: "Sorry, round #{@round} expired while you were sittin' on the fence"
    end
  end

private
  def set_game_and_round
    @game = Game.find(params[:game_id])
    @round = (params[:round] || 0).to_i
  end

  def vote_params
    params.require(:restaurant).permit(:name)
  end
end
