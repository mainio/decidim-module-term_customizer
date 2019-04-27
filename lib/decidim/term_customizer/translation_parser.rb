# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class TranslationParser < Import::Parser
      def self.resource_klass
        Decidim::TermCustomizer::Translation
      end
    end
  end
end
