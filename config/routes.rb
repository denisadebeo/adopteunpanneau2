Rails.application.routes.draw do

  root 'circonscriptions#index'
  get 'panneaus/get_nearest_pannel' =>  'panneaus#get_nearest_pannel'
  get "panneaus/:id/edit_state" => 'panneaus#edit_state', as: :edit_state_panneau_path
  get "panneaus/secret_geo_json_loading" => 'panneaus#secret_geo_json_loading'
  get "google_map" => 'panneaus#google_map', as: :google_map_path
  get "open_street_amp" => 'panneaus#open_street_map', as: :open_street_map_path
  
  get "panneaus_gm" => 'panneaus#google_map'

  resources :panneaus

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end
