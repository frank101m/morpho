module Morpho
  module Resources
    class Unlocks < ::Grape::API
      helpers Morpho::Helpers::HTTPResponses

      namespace :unlocks do
        desc 'Request user unlock token' do
          success Morpho::Grape::DataWrapper.new(Morpho::Entities::UserEmail)
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
          result = Morpho::User::Operation::Unlock.call(params)

          if result.success?
            present result['model'], with: Morpho::Entities::User
          else
            case result['error']
            when :unprocessable_entity
              render_unprocessable_entity(result['contract'].errors)
            when :not_found
              render_not_found({ base: I18n.t('morpho.api.messages.unlock.not_found') })
            when :method_not_allowed
              render_method_not_allowed({ base: I18n.t('morpho.api.messages.unlock.method_not_allowed') })
            else
              render_unprocessable_entity
            end
          end
        end
      end
    end
  end
end
