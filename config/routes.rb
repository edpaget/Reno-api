ZooBuild::Application.routes.draw do
  resource :projects do
    get 'build', to: 'projects#build'

    resource :deploys do
      get 'build', to: 'deploys#build'
    end
  end

  match '*all' => 'application#cors', constraints: { method: 'OPTIONS' }
  mount Resque::Server, :at => "/resque"
end
