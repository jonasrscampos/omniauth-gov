# OmniAuth Gov

Estratégia omniauth para integração do Login Único do governo brasileiro ao autentiador devise.

## Instalação

```ruby
gem 'omniauth', '1.9.2'
gem "omniauth-rails_csrf_protection", '0.1.2'
gem 'omniauth-oauth2'
gem 'omniauth-gov', '~> 0.1.9'
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
    callback_path: '/callback-da-aplicacao',
    client_options: {
      site: 'https://sso.acesso.gov.br', # Ambiente de produção.
      authorize_url: 'https://sso.acesso.gov.br/authorize', # Ambiente de produção.
      token_url: 'https://sso.acesso.gov.br/token' # Ambiente de produção.
    }

    config.omniauth_path_prefix = '/prefixo-devise/prefixo-omniauth'
  end
```

## Initializer
Em `config/initializer/omniauth.rb`

```ruby 
OmniAuth.config.full_host = "https://endereco-do-app.gov.br"
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

  # opcional: redirecionar url de callback para o callback do devise
  devise_scope :user do
    get 'url-de-callback', to: 'auth/omniauth_callbacks#gov'
  end

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

## View
Em `sessions/new.html.erb`
```ruby
      <%= button_to omniauth_authorize_path(resource_name, :gov), class: 'gov-br-btn sign-in br-button middle sign-in w-100 is-primary mt-3 mb-3', data: { turbo: false } do %>
        <i class="icon fa fa-user fa-lg" style="color: rgb(255, 255, 255);"></i>&nbsp;
        <span style="font-weight: normal;">Entrar com</span>&nbsp;
        <span style="font-size: 20px; font-weight: bold;"> gov.br</span>
      <% end %>
```

## Licença
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
