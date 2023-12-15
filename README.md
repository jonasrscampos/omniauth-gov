![Ruby](https://github.com/omniauth/omniauth-gov/workflows/Ruby/badge.svg?branch=main)

# OmniAuth Gov

Estratégia omniauth para integração do Login Único do governo brasileiro ao autentiador devise.

## Instalação

```ruby
gem 'omniauth', '1.9.1'
gem "omniauth-rails_csrf_protection", '0.1.2'
gem 'omniauth-oauth2'
gem 'omniauth-gov', '~> 0.1.0'
```

## Configuração devise

Em `config/initializers/devise.rb.rb`

```ruby
  Devise.setup do |config|
    # ...
    config.omniauth :gov, 
      ENV['client_id'], 
      ENV['client_secret'], 
    scope: 'openid+email+profile+govbr_confiabilidades+', 
    callback_path: '/callback-da-aplicacao'

    config.omniauth_path_prefix = '/prefixo-devise/prefixo-omniauth'
  end
```

## Initializer
Em `config/initializer/omniauth.rb`

```ruby 
OmniAuth.config.full_host = "<host-da-aplicacao-com-protocolo>"
OmniAuth.config.logger = Rails.logger
```

## Route
Em `config/routes.rb`
```ruby
  # ...
  devise_for :users, controllers: {
    # ...
    :omniauth_callbacks => 'auth/omniauth_callbacks'
  }
```

## Controller
Em `controllers/auth/omniauth_callbacks_controller.rb`

```ruby
# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
	skip_before_action :verify_authenticity_token

	def gov
		@user = User.from_gov_br_omniauth(request.env["omniauth.auth"]["info"])

		if @user.id.present?
			sign_in_and_redirect @user, :event => :authentication
			set_flash_message(:notice, :success, :kind => "Login Unico") if is_navigational_format?	  
		else
		end
	end
	
	def failure
    redirect_to root_path
	end

end
```

## Model User
Em `model/user.rb`
```ruby
devise :database_authenticatable,
  # ...
  :omniauthable, omniauth_providers: %i[gov]

  # ...
  def self.from_gov_br_omniauth(info)
    # Exemplo hash info
    # {
    #   "id": 1702579345,
    #   "cpf": '99999999999',
    #   "nome_social": 'Nome Social',
    #   "email_verified": true,
    #   "profile": 'https://servicos.staging.acesso.gov.br/',
    #   "username": '99999999999',
    #   "picture": raw_info["picture"],
    #   "name": raw_info["name"],
    #   "email": raw_info["email"],
    # }    
    user = User.find_by_email(info["email"]) # ou outra chave

    unless user.nil?
      user.update_attributes(provider: 'login-unico', uid: info["id"])
    else
      name = info["name"]
      email = info["email"]
      user = User.new do |user|
        user.name = name
        user.email = email
      end
      user.skip_confirmation!
      user.save
    end

    return user
  end

```
