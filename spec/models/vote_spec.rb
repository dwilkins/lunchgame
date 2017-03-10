require "rails_helper"

describe Vote, type: :model  do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:game) }
  it { is_expected.to belong_to(:restaurant) }


  describe 'factory creation' do
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

    it 'looks them up by id' do
      ids = restaurants.collect(&:id).collect(&:to_s)
      expect(restaurants).to include(*Vote.lookup_restaurants(game,ids))
    end

    it 'looks them up by name' do
      names = restaurants.collect(&:name)
      expect(restaurants).to include(*Vote.lookup_restaurants(game,names))
    end

    it 'looks them up by id or name' do
      id = restaurants.first.id
      name = restaurants.last.name
      expect([restaurants.first,restaurants.last]).to include(*Vote.lookup_restaurants(game,[id,name]))
    end

    it 'does not return duplicates' do
      id = restaurants.first.id
      name = restaurants.last.name
      expect([restaurants.first,restaurants.last]).to include(*Vote.lookup_restaurants(game,[id,id,name]))
    end

    it 'creates votes' do
      id = restaurants.first.id.to_s
      name = restaurants.last.name
      expect{
        Vote.factory(user,game,[id,name])
      }.to change(Vote,:count).by 2
    end

    it 'will not create duplicate votes' do
      id = restaurants.first.id.to_s
      name = restaurants.last.name
      Vote.factory(user,game,[id,name])
      expect{
        Vote.factory(user,game,[id,name])
      }.to change(Vote,:count).by 0
    end

    it 'will not over vote' do
      expect(user).to receive(:can_vote?).with(game).at_least(:once).and_call_original
      id = restaurants.first.id.to_s
      id2 = restaurants.second.id.to_s
      name = restaurants.last.name
      Vote.factory(user,game,[id])
      # Round zero only allows 2 selections (configured above)
      expect{
        Vote.factory(user,game,[id2,name])
      }.to change(Vote,:count).by 1
    end
  end
end
