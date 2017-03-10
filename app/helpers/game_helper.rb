module GameHelper
  # Some handy text telling how many voters have
  # yet to vote in this round
  def waiting_for_voters(game)
    '(Waiting on ' + pluralize(@game.missing_voter_count,'Voter') + ')'
  end
end
