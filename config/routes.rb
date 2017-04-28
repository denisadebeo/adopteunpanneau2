Rails.application.routes.draw do

  root 'circonscriptions#index'
  get 'panneaus/get_nearest_pannel' =>  'panneaus#get_nearest_pannel'
  resources :panneaus
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end
