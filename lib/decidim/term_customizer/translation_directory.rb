# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class TranslationDirectory
      attr_reader :locale

      def initialize(locale)
        @locale = locale.to_sym
      end

      def backend
        @backend ||= original_backend
      end

      def translations
        @translations ||= TranslationStore.new(backend_translations)
      end

      def translations_search(search)
        translations_by_key(search).merge(translations_by_term(search))
      end

      def translations_by_key(search) # rubocop:disable Rails/Delegate
        translations.by_key(search)
      end

      def translations_by_term(search, case_sensitive: false)
        translations.by_term(search, case_sensitive:)
      end

      private

      def original_backend
        if I18n.backend.instance_of?(I18n::Backend::Chain)
          return I18n.backend.backends.find do |be|
            be.instance_of?(I18n::Backend::Simple)
          end
        end

        I18n.backend
      end

      def backend_translations
        list = backend.translations(do_init: true)
        list[locale]
      end
    end
  end
end
