require "rails_helper"

describe Game, type: :model  do
  let(:games_params) do
    [
      {
       required_voter_count: 4,
       round: 0,
       number_of_selections: 2,
       created_at: DateTime.now - 1.day,
       updated_at: DateTime.now - 1.day,
      },
      {
       required_voter_count: 4,
       round: 0,
       number_of_selections: 2,
       created_at: DateTime.now,
       updated_at: DateTime.now
      },
      {
        required_voter_count: 4,
        round: 0,
        number_of_selections: 2,
        created_at: DateTime.now + 1.day,
        updated_at: DateTime.now + 1.day
      }
    ]
  end

  let(:restaurants_params) do
    [
      {
        name: 'Best'
      },
      {
        name: 'SoSo'
      },
      {
        name: 'Worst'
      },
    ]
  end

  let(:users_params) do
    [
      {
        email: 'natsass@example.com',
        password: 'P@sswordTest',
        password_confirmation: 'P@sswordTest',
        name: 'Nathan Sass'
      },
      {
        email: 'user0@example.com',
        password: 'P@sswordTest',
        password_confirmation: 'P@sswordTest',
        name: 'username0'
      },
      {
        email: 'user1@example.com',
        password: 'P@sswordTest',
        password_confirmation: 'P@sswordTest',
        name: 'username1'
      },
      {
        email: 'user2@example.com',
        password: 'P@sswordTest',
        password_confirmation: 'P@sswordTest',
        name: 'username2'
      }
    ]
  end


  it { is_expected.to have_many(:votes) }
  it { is_expected.to have_many(:round_0_votes).class_name('Vote') }
  it { is_expected.to have_many(:round_1_votes).class_name('Vote') }
  it { is_expected.to have_many(:round_2_votes).class_name('Vote') }
  it { is_expected.to have_many(:round_0_voters).class_name('User') }
  it { is_expected.to have_many(:round_1_voters).class_name('User') }
  it { is_expected.to have_many(:round_2_voters).class_name('User') }
  it { is_expected.to have_many(:restaurants) }
  it { is_expected.to have_many(:selected_restaurants) }
  it { is_expected.to have_many(:eliminated_restaurants) }

  it {
    skip 'required_voter_count should be final vote count + 1 to avoid a draw'
    is_expected.to validate_numericality_of(:required_voter_count).is_greater_than(3)
  }

  it 'finds the current game' do
    Game.create(games_params)
    expect(Game.current.created_at.utc.to_s).to eq games_params[1][:created_at].utc.to_s
  end

  it 'recognizes expired games' do
    games = Game.create(games_params)
    expect(games[0]).to be_expired
  end

  describe 'missing voters' do
    it 'calcuates missing voters' do
      Game.create(games_params)
      game = Game.current
      allow(game).to receive(:current_voter_count).and_return(1)
      expect(game.missing_voter_count).to eq 3
    end
  end

  describe 'with rounds' do
    before(:each) do
      Game.create(games_params)
      User.create(users_params)
      Restaurant.create(restaurants_params)
      # user = User.first
      # game = Game.current
      # restaurants = Restaurant.all.limit(game.number_of_selections)
    end

    let(:users) { User.all }

    def stuff_votes game, user,restaurants
      restaurants.each do |r|
        Vote.create(restaurant_id: r.id,
                    user_id: user.id,
                    game_id: game.id,
                    round: game.round
                   )
      end
    end

    describe 'votes' do
      it 'calculates max_votes' do
        game = Game.current
        expect(game.max_votes).to eq game.number_of_selections
        game.round += 1
        expect(game.max_votes).to eq 1
        game.round += 1
        ## in round 2, you can vote 3 times, but that doesn't work
        ## when there are only 2 selections, so the length of available_selections
        ## will cap the max_votes available in Round 2
        allow(game).to receive(:available_selections).and_return([0,0,0]) # length 3
        expect(game.max_votes).to eq 3
        game.round += 1
        expect(game.max_votes).to eq 0
      end

      it 'calcuates current' do
        game = Game.current
        restaurants = Restaurant.all
        (0...game.required_voter_count).each do |idx|
          stuff_votes(game,users[idx],restaurants.sample(game.number_of_selections))
          game.reload
          expect(game.current_vote_count).to eq game.number_of_selections * (idx+1)
        end
      end

      it 'determine when the round is complete' do
        game = Game.current
        restaurants = Restaurant.all.limit(game.number_of_selections)
        expect(game.round_completed?).to be_falsy
        expect{
          game.update_round
        }.to_not change(game,:round)
        (0...game.required_voter_count).each do |idx|
          stuff_votes(game,users[idx],restaurants)
          game.reload
        end
        expect(game.round_completed?).to be_truthy
        expect{
          game.update_round
        }.to change(game,:round).by(1)
      end
    end

    describe 'available selections' do
      let(:game) {
        game = Game.current
      }

      let(:voted_for_restaurants) {
        Restaurant.all.limit(game.number_of_selections)
      }

      let(:not_voted_for_restaurants) {
        Restaurant.where.not(id: voted_for_restaurants)
      }

      let(:eliminated_restaurants) {
        [voted_for_restaurants.first]
      }

      let(:not_eliminated_restaurants) {
        voted_for_restaurants - eliminated_restaurants
      }

      let(:do_round_0) do
        expect(voted_for_restaurants.count).to be > 1
        expect(not_voted_for_restaurants.count).to be > 0
        expect(game.available_selections).to contain_exactly(*Restaurant.all)
        (0...game.required_voter_count).each do |idx|
          stuff_votes(game,users[idx],voted_for_restaurants)
          game.reload
        end
        expect{
          game.update_round.save
        }.to change(game,:round).by(1)
        true
      end

      let(:do_round_1) do
        expect(do_round_0).to be_truthy
        (0...game.required_voter_count).each do |idx|
          stuff_votes(game,users[idx],eliminated_restaurants)
          game.reload
        end
        expect {
          game.update_round.save
        }.to change(game,:round).by(1)
        true
      end

      it 'after round 0' do
        expect(do_round_0).to be_truthy
        expect(game.available_selections).to contain_exactly(*voted_for_restaurants)
        expect(game.available_selections).to_not include(*not_voted_for_restaurants)
      end

      it 'after round 1' do
        expect(do_round_1).to be_truthy
        expect(game.available_selections).to contain_exactly(*not_eliminated_restaurants)
        expect(game.available_selections).to_not include(*eliminated_restaurants)
      end
    end

  end
end
