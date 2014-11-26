Rails.application.routes.draw do
  root :to => "catalog#index"
  blacklight_for :catalog

  get '/orcid_stats', :to => 'orcid_stats#index'
end
