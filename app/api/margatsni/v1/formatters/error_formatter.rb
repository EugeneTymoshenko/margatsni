# frozen_string_literal: true

module Margatsni
  module V1
    module Formatters
      module ErrorFormatter
        def self.call(message, backtrace, options, env, original_exception)
          formatter =
            if original_exception.is_a?(Grape::Exceptions::ValidationErrors)
              format_grape_error(message)
            else
              message
            end

          { errors: formatter }.to_json
        end

        def self.format_error(message)
          words = message.split
          { words.first.downcase => [words[1..-1].join(' ')] }
        end

        def self.format_grape_error(message)
          case message
          when Array
            message.map { |element| format_error(element) }
          when String
            format_error(message)
          else
            message
          end
        end
      end
    end
  end
end
