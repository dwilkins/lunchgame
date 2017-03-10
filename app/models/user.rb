class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :votes

  def votes_cast(game,round = nil)
    round ||= game.round
    votes.where(game: game, round: round).limit(game.max_votes(round))
  end

  def votes_remaining(game,round = nil)
    round ||= game.round
    remaining = game.max_votes(round) - votes_cast(game,round).count
    remaining < 0 ? 0 : remaining
  end

  def can_vote?(game)
    return false if game.created_at.localtime.to_date != DateTime.now.to_date
    case game.round
    when 0
      votes_remaining(game) > 0
    when 1..2
      game.round_0_voters.exists?(id) && votes_remaining(game) > 0
    else
      false
    end
  end

end
