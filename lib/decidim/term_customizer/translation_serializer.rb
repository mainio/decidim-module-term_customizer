# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # This class serializes a Proposal so can be exported to CSV, JSON or other
    # formats.
    class TranslationSerializer < Decidim::Exporters::Serializer
      # Public: Initializes the serializer with a proposal.
      def initialize(translation)
        @translation = translation
      end

      # Public: Exports a hash with the serialized data for this proposal.
      def serialize
        {
          id: translation.id,
          locale: translation.locale,
          key: translation.key,
          value: translation.value
        }
      end

      private

      attr_reader :translation
    end
  end
end
