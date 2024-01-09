# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class TranslationStore
      def initialize(hash)
        @values = flat_hash(hash || {})
      end

      def term(key)
        @values[key]
      end

      def by_key(search)
        @values.select do |key|
          includes_string?(key, search, case_sensitive: true)
        end
      end

      def by_term(search, case_sensitive: false)
        @values.select do |_key, term|
          includes_string?(term, search, case_sensitive:)
        end
      end

      private

      def includes_string?(source, search, case_sensitive: false)
        return source.include?(search) if case_sensitive

        source.downcase.include?(search.downcase)
      end

      def flat_hash(hash)
        hash.each_with_object({}) do |(k, v), h|
          if v.is_a? Hash
            flat_hash(v).map do |h_k, h_v|
              append_to_hash(h, "#{k}.#{h_k}", h_v)
            end
          else
            append_to_hash(h, k.to_s, v)
          end
        end
      end

      def append_to_hash(hash, key, value)
        # Specific translations have a proc value but in our context these
        # translations are not interesting. An example of such translation is
        # `i18n.plural.rule` which takes in an integer when called and returns
        # either `:one` or `:other` depending on the integer's value.
        return if value.is_a?(Proc)

        # Some translation values are symbols which are also not interesting in
        # our context. Example of such translation is `i18n.plural.rule` which
        # has a value of `[:one, :other]`.
        return if value.is_a?(Symbol)

        # Exclude the faker translations.
        return if /^faker\./.match?(key)

        if value.is_a?(Array)
          value.each_with_index do |v, i|
            append_to_hash(hash, "#{key}.#{i}", v)
          end
        else
          hash[key] = value.to_s
        end
      end
    end
  end
end
