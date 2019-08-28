# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # Checks that all the plural forms are in the database for the given keys.
    class PluralFormsManager
      attr_reader :organization

      @plural_keys = [:zero, :one, :few, :other]

      class << self
        attr_accessor :plural_keys
      end

      def initialize(organization)
        @organization = organization
        @default_locale = organization.default_locale
      end

      def fill!(translations)
        each_plural_form(translations) do |translation, key|
          add_locales_for!(translation, key)
        end
      end

      def destroy!(translations)
        each_plural_form(translations) do |translation, key|
          destroy_locales_for!(translation, key)
        end
      end

      private

      attr_reader :default_locale

      def each_plural_form(translations)
        keys = self.class.plural_keys.map(&:to_s)
        translations.each do |tr|
          # Check that the last part of the translation key matches with some
          # of the plural translation keys.
          next unless tr.key =~ /\.(#{keys.join("|")})$/

          parts = tr.key.split(".")
          plural_part = parts.pop
          base_part = parts.join(".")

          # If it's not a hash, it's not a plural translation
          next unless I18n.exists?(base_part, default_locale)
          next unless I18n.t(base_part, locale: default_locale).is_a?(Hash)

          keys.each do |plural_key|
            # Do not check for the translation itself
            next if plural_part == plural_key

            full_plural_key = "#{base_part}.#{plural_key}"

            # Check that the translation actually exists, no need to process if
            # it does not exist.
            next unless I18n.exists?(full_plural_key, default_locale)

            yield tr, full_plural_key
          end
        end
      end

      def add_locales_for!(translation, target_key)
        organization.available_locales.each do |locale|
          # Skip adding the plural form for the translation itself
          next if target_key == translation.key

          # Check that the translation is not already added in the set
          next if translation.translation_set.translations.where(
            key: target_key,
            locale: locale
          ).any?

          # Add the plural form
          translation.translation_set.translations.create!(
            key: target_key,
            locale: locale,
            value: I18n.t(target_key, locale: locale, default: "")
          )
        end
      end

      def destroy_locales_for!(translation, target_key)
        organization.available_locales.each do |locale|
          # Skip deleting the plural form for the translation itself
          next if target_key == translation.key

          # Find the plural form the plural form
          target = translation.translation_set.translations.find_by(
            key: target_key,
            locale: locale
          )
          next unless target

          target.destroy!
        end
      end
    end
  end
end
