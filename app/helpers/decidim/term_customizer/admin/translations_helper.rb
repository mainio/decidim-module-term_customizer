# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      module TranslationsHelper
        # Public: A formatted collection of mime_type to be used
        # in forms.
        def mime_types
          types = ""
          accepted_mime_types = Decidim::TermCustomizer::Import::Readers::ACCEPTED_MIME_TYPES.keys
          accepted_mime_types.each_with_index do |mime_type, index|
            types += t(".accepted_mime_types.#{mime_type}")
            types += ", " unless accepted_mime_types.length == index + 1
          end
          types
        end
      end
    end
  end
end
