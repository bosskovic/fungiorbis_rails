require 'api_constraints'

Rails.application.routes.draw do

  scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true), defaults: {format: 'json'} do
    devise_for :users, controllers: {
        registrations: 'v1/custom_devise/registrations'
    }
    resources :users, :only => [:index, :create]
  end

  root to: 'home#index'
end
