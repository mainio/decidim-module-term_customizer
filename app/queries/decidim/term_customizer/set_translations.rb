# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # This query class filters all assemblies given an organization.
    class SetTranslations < Decidim::Query
      def initialize(translation_set, locale = nil)
        @translation_set = translation_set
        @locale = locale
      end

      def query
        q = Decidim::TermCustomizer::Translation.where(
          translation_set: @translation_set
        )
        q = q.where(locale: @locale) if @locale
        q.order(:key)
      end
    end
  end
end
