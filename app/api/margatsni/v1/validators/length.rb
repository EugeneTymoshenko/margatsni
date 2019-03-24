# frozen_string_literal: true

module Margatsni
  module V1
    module Validators
      class Length < Grape::Validations::Base
        def validate_param!(attr_name, params)
          return if params[attr_name] && params[attr_name].length <= @option

          raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)],
                                               message: I18n.t('errors.messages.length_error', option: @option)
        end
      end
    end
  end
end
