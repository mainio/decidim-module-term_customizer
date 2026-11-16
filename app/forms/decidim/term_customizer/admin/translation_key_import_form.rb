# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationKeyImportForm < Decidim::Form
        mimic :translation

        delegate :translation_set, to: :context, prefix: false, allow_nil: true

        attribute :keys, [String]
      end
    end
  end
end
