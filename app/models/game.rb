class Game < ApplicationRecord

  has_many :votes
  has_many :round_0_votes, -> { where(round: 0) }, class_name: 'Vote'
  has_many :round_1_votes, -> { where(round: 1) }, class_name: 'Vote'
  has_many :round_2_votes, -> { where(round: 2) }, class_name: 'Vote'
  has_many :round_0_voters, -> { distinct },  through: :round_0_votes, class_name: 'User', source: :user
  has_many :round_1_voters, -> { distinct }, through: :round_1_votes, class_name: 'User', source: :user
  has_many :round_2_voters, -> { distinct }, through: :round_2_votes, class_name: 'User', source: :user
  has_many :voters, -> { distinct }, through: :votes, class_name: 'User', source: :user
  has_many :restaurants, -> { distinct }, through: :votes, inverse_of: :games
  has_many :selected_restaurants, -> { distinct }, through: :round_0_votes, source: :restaurant
  has_many :eliminated_restaurants, -> { distinct }, through: :round_1_votes, source: :restaurant

  validates :required_voter_count, presence: true, numericality: { greater_than: 0 }

  def self.current
    where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day).first
  end

  def winning_restaurants
    Restaurant.joins(:votes).merge(round_2_votes).group(:id).order(count: :desc)
  end

  def missing_voter_count
    required_voter_count - current_voter_count
  end

  def current_voter_count
    case round
    when 0
      round_0_voters.count
    when 1
      round_1_voters.count
    when 2
      round_2_voters.count
    else
      required_voter_count
    end
  end

  def current_vote_count
    case round
    when 0
      round_0_votes.count
    when 1
      round_1_votes.count
    when 2
      round_2_votes.count
    else
      0
    end
  end


  def round_completed?
    created_at.localtime.to_date == DateTime.now.to_date &&
      current_vote_count >= (required_voter_count * max_votes)
  end

  def expired?
    created_at.localtime.to_date < DateTime.now.to_date
  end


  def update_round
    if persisted? && !expired? && round_completed? && round < 3
      self.round += 1
    end
    self
  end

  def name
    (created_at || DateTime.now).localtime.strftime("%A, %d-%b-%Y")
  end

  # Maximum votes for a user in a round
  def max_votes(which_round = nil)
    which_round ||= self.round
    [number_of_selections,1,[3,available_selections.length].min,0][which_round]
  end

  def to_s
    (created_at || DateTime.now).localtime.strftime("%A, %d-%b-%Y")
  end

  # available restaurants to select from in a particular round
  def available_selections
    case round
    when 0
      Restaurant.all
    when 1
      selected_restaurants
    when 2
      selected_restaurants - eliminated_restaurants
    when 3
      winning_restaurants
    end
  end


end
