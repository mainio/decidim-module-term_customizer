# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationForm < Decidim::Form
        include TranslatableAttributes

        mimic :translation

        delegate :translation_set, to: :context, prefix: false, allow_nil: true

        attribute :key, String
        translatable_attribute :value, String

        def map_model(model)
          self.value = Hash[Decidim::TermCustomizer::Translation.where(
            translation_set: model.translation_set,
            key: model.key
          ).map do |translation|
            [translation.locale, translation.value]
          end]
        end
      end
    end
  end
end
