AttachmentsIO::Application.routes.draw do
  get "streaming/events"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'pages#home'

  # User profile
  match '/profile' => 'profile#show', via: :get, as: :profile
  match '/profile/settings' => 'profile#settings', via: [:get, :patch], as: :user_settings

  # Sign In / Sign Out
  match '/signin/google' => 'signin#google', via: :get, as: :sign_in_google
  match '/signin/apps(/:domain)' => 'signin#apps', via: [:get, :post], constraints: { domain: /[0-z\.]+/ }, as: :sign_in_apps
  match '/signout' => 'sessions#destroy', via: [:get, :delete], as: :sign_out

  # Google OAuth2 Callback
  match '/auth/google/callback' => 'sessions#create_google', via: [:get, :post]

  # Synchronization
  match '/sync/start' => 'sync#start', via: :get, as: :sync_start
  match '/sync/details/:id' => 'sync#details', via: :get, as: :sync_details

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
