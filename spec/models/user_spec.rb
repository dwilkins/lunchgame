require "rails_helper"

describe User, type: :model  do
  it { is_expected.to have_many(:votes) }

  describe 'votes' do
    let(:game_params) {
      {
        required_voter_count: 4,
        round: 0,
        number_of_selections: 2,
        created_at: DateTime.now,
        updated_at: DateTime.now
      }
    }
    let(:game) {
      Game.create(game_params)
    }
    let(:restaurants_params) {
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
    }
    let(:restaurants) {
      Restaurant.create(restaurants_params)
    }
    let(:user_params) {
      {
        email: 'natsass@example.com',
        password: 'P@sswordTest',
        password_confirmation: 'P@sswordTest',
        name: 'Nathan Sass'
      }
    }
    let(:user) {
      User.create(user_params)
    }

    before(:each) do
      expect(restaurants).to_not be_nil
      expect(game).to_not be_nil
      expect(user).to_not be_nil
    end
      describe 'cast' do

      it 'counts votes' do
        expect(user.votes_cast(game).count).to eq 0
        expect{
          Vote.factory(user,game,restaurants.collect(&:id))
        }.to change(Vote,:count).by game.number_of_selections
        user.reload
        expect(user.votes_cast(game).count).to eq game.max_votes
      end

      it 'counts votes per round' do
        expect{
          Vote.factory(user,game,restaurants.collect(&:id))
        }.to change(Vote,:count).by game.number_of_selections
        user.reload
        game.round +=1
        expect(user.votes_cast(game).count).to eq 0
      end
    end
    describe 'remaining' do
      it "calculates positive" do
        allow(user).to receive(:votes_cast).with(game,0).and_return([0]) # countable - 1 vote
        expect(user.votes_remaining(game)).to eq 1
      end

      it "calculates 0" do
        allow(user).to receive(:votes_cast).with(game,0).and_return([0,0]) # countable - 2 votes
        expect(user.votes_remaining(game)).to eq 0
      end

      it "calculates 0 with too many votes" do
        allow(user).to receive(:votes_cast).with(game,0).and_return([0,0,0,0]) # countable - 4 votes
        expect(user.votes_remaining(game)).to eq 0
      end
    end
    describe 'can_vote?' do
      it 'still votes remaining' do
        allow(user).to receive(:votes_remaining).with(game).and_return(1)
        expect(user.can_vote?(game)).to be_truthy
      end
      it 'no votes remaining' do
        allow(user).to receive(:votes_remaining).with(game).and_return(0)
        expect(user.can_vote?(game)).to be_falsy
      end
    end

  end
end
