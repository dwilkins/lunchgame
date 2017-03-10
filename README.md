# README


## The Lunch Game

* Setup
  * Number of players
  * Number of restaurants per player

* Round 0 - Setup
  * Inputs
    * Player Name or ID
    * Restaurant(s)
  * Outputs:
    * Wait until all players have input their name/ID + restaurants

* Round 1 - Elimination
  * Display a List of the Restaurants
  * Inputs:
    * Each player can eliminate 1 restaurant
  * Outputs:
    * Wait until each player elminates a restaurant
    * Update the list after an elminination

* Round 2 - Vote
  * Display Remaining List of Restaurants
  * Inputs:
    Each player has 3 votes, can use all 3 and can only vote for a restaurant once
  * Outputs:
    * Wait until each player has voted
    * Display vote tallies and show the winner

* Bonus
  * Restaurant String Matching to consolidate duplicate restaurants. ie. 3 people choose Saws
  * Saws has 3 entries in round 1
  * If Saws has makes it to round 3 and wasn't eliminated, it has 3 votes


## Installation

* RVM, Rails 5, Postgres, etc...

```
clone the repo
cd lunchgame
gem install bundler
bundle
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rspec
bundle exec rails s
PROFIT
```
