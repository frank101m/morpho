module Morpho
  module Resources
    class Activations < ::Grape::API
      helpers Morpho::Helpers::HTTPResponses

      namespace :activations do
        desc 'Request user activation token' do
          success Morpho::Grape::DataWrapper.new(Morpho::Entities::User)
          failure [
            [ 404, I18n.t('morpho.api.messages.not_found'), Morpho::Entities::Error ],
            [ 405, I18n.t('morpho.api.messages.method_not_allowed'), Morpho::Entities::Error ],
            [ 422, I18n.t('morpho.api.messages.unprocessable_entity'), Morpho::Entities::Error ]
          ]
        end
        params do
          requires :data, type: Morpho::Entities::UserEmail
        end
        post do
          result = Morpho::User::Operation::Activate.call(params)

          if result.success?
            present result['model'], with: Morpho::Entities::User
          else
            case result['error']
            when :not_valid
              render_unprocessable_entity_detailed(result['contract'].errors)
            when :not_found
              render_not_found
            when :not_allowed
              render_method_not_allowed
            when :not_delivered
              render_unprocessable_entity
            else
              render_unprocessable_entity
            end
          end
        end
      end
    end
  end
end
