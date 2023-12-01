require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Gov < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: 'https://sso.staging.acesso.gov.br',
        authorize_url: 'https://sso.staging.acesso.gov.br/authorize',
        token_url: 'https://sso.staging.acesso.gov.br/token'
      }
      
      option :pkce, true

      option :pkce_options, {
        :code_challenge => proc { |verifier|
          Base64.urlsafe_encode64(
            Digest::SHA2.digest(verifier),
            :padding => false,
          )
        },
        :code_challenge_method => "S256",
      }

      uid{ raw_info['id'] }

      info do
        {
          :name => raw_info['name'],
          :email => raw_info['email'],
          :cpf => raw_info['sub']
        }
      end

      extra do
        {
          'raw_info' => raw_info, 'uid' => uid
        }
      end

      def raw_info
        @raw_info ||= access_token.get('id_token').parsed
      end

      def uid
        @uid ||= access_token.get('access_token/jti').parsed
      end

    end
  end
end

OmniAuth.config.add_camelization 'gov', 'Gov'
