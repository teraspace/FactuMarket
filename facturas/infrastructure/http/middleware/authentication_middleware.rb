require 'json'

module Facturas
  module Infrastructure
    module Http
      module Middleware
        class AuthenticationMiddleware
          def initialize(app)
            @app = app
          end

          def call(env)
            request = Rack::Request.new(env)
            return @app.call(env) if public_path?(request.path_info)

            token = extract_token(request)
            if token && token == ENV['API_TOKEN']
              @app.call(env)
            else
              unauthorized_response
            end
          end

          private

          def extract_token(request)
            header = request.get_header('HTTP_AUTHORIZATION')
            return nil unless header

            scheme, token = header.split(' ')
            scheme&.casecmp('Bearer')&.zero? ? token : nil
          end

          def public_path?(path)
            path == '/health'
          end

          def unauthorized_response
            [
              401,
              { 'Content-Type' => 'application/json' },
              [JSON.generate(error: 'Unauthorized')]
            ]
          end
        end
      end
    end
  end
end
