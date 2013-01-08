ZooBuild::Application.routes.draw do
  get "deploys/build"

  resources :projects do
    get 'build', to: 'projects#build'

    resources :deploys do
      get 'build', to: 'deploys#build'
    end
  end

  match '*all' => 'application#cors', constraints: { method: 'OPTIONS' }
  mount Resque::Server, :at => "/resque"
end
