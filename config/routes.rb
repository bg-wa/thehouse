Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/' => 'application#intent_handler'
  post '/' => 'application#intent_handler', :as => 'root'
end
