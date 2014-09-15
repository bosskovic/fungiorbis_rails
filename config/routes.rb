require 'fungiorbis/api_constraints'

Rails.application.routes.draw do

  scope module: :v1, constraints: Fungiorbis::ApiConstraints.new(version: 1, default: :true, domain: APPLICATION_DOMAIN), defaults: { format: 'json' } do
    devise_for :users, controllers: {
        registrations: 'v1/custom_devise/registrations',
        confirmations: 'v1/custom_devise/confirmations',
        sessions: 'v1/custom_devise/sessions'
    }
    resources :users, only: [:index, :show, :update], param: :uuid
    resources :species, only: [:index, :show, :create, :update, :destroy], param: :uuid
    resources :references, only: [:index, :show, :create, :update, :destroy], param: :uuid
  end

end
