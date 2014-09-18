Rails.application.routes.draw do
  root :to => "catalog#index"
  blacklight_for :catalog
end
