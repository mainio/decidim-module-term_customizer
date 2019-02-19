# frozen_string_literal: true

require "i18n/backend/base"
require "i18n/backend/flatten"

module Decidim
  module TermCustomizer
    class I18nBackend
      using I18n::HashRefinements

      (class << self; self; end).class_eval { public :include }

      module Implementation
        include I18n::Backend::Base

        # Get available locales from the translations hash
        def available_locales
          Translation.available_locales
        rescue ::ActiveRecord::StatementInvalid
          []
        end

        # Clean up translations hash on reload!
        def reload!
          @translations = nil
          super
        end

        def translations
          return @translations if @translations
          return {} unless TermCustomizer.resolver

          @translations = {}

          TermCustomizer.resolver.translations.each do |tr|
            keyparts = [tr.locale] + tr.key.split(".")
            lastkey = keyparts.pop.to_sym

            current = @translations
            keyparts.each do |key|
              current[key.to_sym] ||= {}
              current = current[key.to_sym]
            end

            current[lastkey] = tr.value
          end

          @translations
        end

        protected

        # Looks up a translation from the translations hash. Returns nil if
        # either key is nil, or locale, scope or key do not exist as a key in
        # the nested translations hash. Splits keys or scopes containing dots
        # into multiple keys, i.e. <tt>currency.format</tt> is regarded the same
        # as <tt>%w(currency format)</tt>.
        def lookup(locale, key, scope = [], options = EMPTY_HASH)
          keys = I18n.normalize_keys(locale, key, scope, options[:separator])

          keys.inject(translations) do |result, inner_key|
            return nil unless result.is_a?(Hash)

            unless result.has_key?(inner_key)
              inner_key = inner_key.to_s.to_sym
              return nil unless result.has_key?(inner_key)
            end
            result = result[inner_key]
            result = resolve(locale, inner_key, result, options.merge(scope: nil)) if result.is_a?(Symbol)
            result
          end
        end
      end

      include Implementation
    end
  end
end
