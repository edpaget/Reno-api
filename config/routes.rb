ZooBuild::Application.routes.draw do
  resources :projects do
    get 'build', to: 'projects#build'

    resources :deploys do
      get 'build', to: 'deploys#build'
    end
  end

  post "projects/webhook", to: 'projects#webhook'
  get "messages", to: 'messages#index'
  get 'users', to: 'users#index'
  match '/auth/:provider/callback', to: 'sessions#create'
  match '*all' => 'application#cors', constraints: { method: 'OPTIONS' }
  mount Resque::Server, :at => "/resque"
end
