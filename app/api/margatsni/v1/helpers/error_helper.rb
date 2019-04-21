module Margatsni
  module V1
    module Helpers
      module ErrorHelper
        def not_found!(key:, value: ['not found'], status: 404)
          error!({ key => value }, status)
        end
      end
    end
  end
end
