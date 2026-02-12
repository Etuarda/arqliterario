Rails.application.routes.draw do
  devise_for :users

  resources :books do
    collection do
      # Esta é a rota que seu JavaScript chama para a Open Library
      get :search 
    end
  end

  # Define a página inicial como a lista de livros
  root "books#index" 
end