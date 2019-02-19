# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class I18nBackend
      include I18n::Backend::Base

      def translate(locale, key, options = {})
        raise I18n::InvalidLocale, locale unless locale

        entry = key && lookup(locale, key, options[:scope], options)

        if options.empty?
          entry = resolve(locale, key, entry, options)
        else
          count, default = options.values_at(:count, :default)
          # significant speedup over Hash#except
          values = options.reject { |key, value| RESERVED_KEY_MAP.key?(key) }
          entry = entry.nil? && default ?
            default(locale, key, default, options) : resolve(locale, key, entry, options)
        end

        throw(:exception, I18n::MissingTranslation.new(locale, key, options)) if entry.nil?
        # no need to dup, since I18nema gives us a new string

        entry = pluralize(locale, entry, count) if count
        entry = interpolate(locale, entry, values) if values
        entry
      end

      def store_translations(locale, data, options = {})
        # TODO: make this moar awesome
        @initialized = true
        load_yml_string({locale => data}.deep_stringify_keys.to_yaml)
      end

      def init_translations
        load_translations
        @initialized = true
      end

      class Store
        include I18nAdmin::RequestStore

        def [](path)
          locale, key = locale_and_key_from(path)
          cached_translations_for(locale).translations[key]
        end

        def translations_for(locale)
          translations_set_for(locale).translations
        end

        private

        def locale_and_key_from(path)
          path.split('.', 2)
        end

        def translations_set_for(locale)
          model.where(locale: locale).first_or_initialize do |set|
            set.translations ||= {}
          end
        end

        def cached_translations_for(locale)
          store_key = store_key_for(locale, :set)
          request_store.store[store_key] ||= translations_set_for(locale)
        end

        def model
          @model ||= I18nAdmin::TranslationsSet
        end
      end

      def initialize
        @store = HstoreBackend::Store.new
      end

      def store_translations(locale, data, options = {})
        data.each do |key, value|
          store.store_translations(locale, key, value)
        end
      end

      protected

      def lookup(locale, key, scope = [], options = {})
        key = normalize_flat_keys(locale, key, scope, options[:separator])
        store["#{locale}.#{key}"]
      end
    end
  end
end
