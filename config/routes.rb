Rails.application.routes.draw do
  resources :votes, only: [:create]

  resources :games do
    collection do
      get  'current'
    end
  end
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'games#current'
end
