class Restaurant < ApplicationRecord
  has_many :votes
  has_many :games, -> { distinct }, through: :votes, inverse_of: :restaurants
  has_many :round_1_votes, -> { where(round: 1) }, class_name: 'Vote'
  has_many :round_2_votes, -> { where(round: 2) }, class_name: 'Vote'

  validates :name, presence: true, length: { minimum: 4, maximum: 100 }

end
