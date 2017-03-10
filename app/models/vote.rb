class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :game
  belongs_to :restaurant


  def self.factory(user,game,restaurants)
    lookup_restaurants(game,restaurants).collect do |restaurant|
      if user.can_vote?(game)
        vote = Vote.find_or_initialize_by(user_id: user.id,
                                          game_id: game.id,
                                            round: game.round,
                                            restaurant_id: restaurant.id)
        unless(vote.persisted?)
          vote.save
          vote
        else  # no need to report votes we didn't make
          nil
        end
      end
    end.compact
  end

  def self.lookup_restaurants game,restaurants
    restaurants.collect do |r|
      r = r.to_s
      r.gsub!(/^0+/,'') # strip leading zeros
      if(r.blank?)
        nil
      elsif(r.to_i.to_s == r)  # it's an ID
        Restaurant.find(r)
      elsif(game.round == 0)               # must be a name
        new_restaurant = Restaurant.find_or_create_by(name: r)
        new_restaurant.persisted? ? new_restaurant : nil
      else
        nil
      end
    end.compact.uniq[0...game.number_of_selections]

  end

end
