Photobooth::Application.routes.draw do
  
  resources :photos do
    member do
      put :toggle_published
    end
  end

  devise_for :admins
  
  match '/cam' => 'photos#cam'
  match '/camerasnap' => 'photos#camerasnap', :via => :post
  
  root :to => "photos#cam"

end
