# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # A form object to be used when admin users wants to destroy multiple
      # translations at once.
      class TranslationsDestroyForm < Decidim::Form
        mimic :translations_destroy

        delegate :translation_set, to: :context, prefix: false, allow_nil: true

        attribute :translation_ids, Array
        validates :translation_set, :translations, presence: true

        # Translations for all locales corresponding the translations passed
        # to the form.
        def translations
          return [] unless translation_set

          @translations ||= translation_set.translations.where(
            key: translation_keys
          ).order(:id)
        end

        # Only the translations passed with the IDs (current locale).
        def translations_current
          return [] unless translation_set

          @translations_current ||= translation_set.translations.where(
            id: translation_ids.uniq
          ).order(:id)
        end

        private

        # Because we want to delete all locales for the translations to be
        # deleted, find the corresponding keys for the translation IDs passed
        # from the UI (current locale).
        def translation_keys
          @translation_keys ||= translations_current.map(&:key).uniq
        end
      end
    end
  end
end
