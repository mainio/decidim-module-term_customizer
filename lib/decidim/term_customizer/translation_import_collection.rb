# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class TranslationImportCollection
      def initialize(translation_set, records, locales)
        @translation_set = translation_set
        @records = records
        @locales = locales
      end

      def import_attributes
        attributes_for_all_locales
      end

      private

      attr_reader :translation_set, :records, :locales

      def collection_attributes
        @collection_attributes ||= records.map do |translation|
          # Skip all translation keys that already exists
          next if translation_set.translations.where(
            key: translation.key
          ).present?

          {
            locale: translation.locale,
            key: translation.key,
            value: translation.value
          }
        end.compact
      end

      def unique_attributes
        @unique_attributes ||= collection_attributes.uniq do |attr|
          "#{attr[:locale]}.#{attr[:key]}"
        end
      end

      def attribute_keys
        @attribute_keys ||= unique_attributes.map { |attr| attr[:key] }.uniq
      end

      def attributes_for_all_locales
        @attributes_for_all_locales ||= attribute_keys.map do |key|
          locales.map do |locale|
            # Find if the item with the locale already exists in the
            # unique collection.
            item = unique_attributes.find do |attr|
              attr[:key] == key && attr[:locale] == locale.to_s
            end

            # In case the item does not exist for the key and locale, create
            # a new item with the default I18n translation. Otherwise, return
            # the found item to the final array.
            if item.nil?
              {
                key: key,
                locale: locale.to_s,
                value: I18n.t(key, locale: locale, default: "")
              }
            else
              item
            end
          end
        end.flatten
      end
    end
  end
end
