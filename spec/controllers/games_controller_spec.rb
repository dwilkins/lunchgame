require "rails_helper"

describe GamesController, type: :controller  do
  let(:authorized_user) do
    User.create ({
                   email: 'natsass@example.com',
                   password: 'P@sswordTest',
                   password_confirmation: 'P@sswordTest',
                   name: 'Nathan Sass'
                 })
  end

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

  describe 'index' do
    it 'get some games' do
      games = Game.create(games_params)
      as_user authorized_user do
        get :index, {}
      end
      expect(response).to have_http_status(:success)
      expect(assigns(:games)).to contain_exactly(*games)
    end
    it 'empty without games' do
      as_user authorized_user do
        get :index, {}
      end
      expect(response).to have_http_status(:success)
      expect(assigns(:games)).to be_empty
    end
  end

end
