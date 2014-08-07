require 'api_constraints'

Rails.application.routes.draw do

  scope module: :v1, constraints: ApiConstraints.new(version: 1, default: :true), defaults: {format: 'json'} do
    resources :users, :only => [:index, :create]
  end

end
