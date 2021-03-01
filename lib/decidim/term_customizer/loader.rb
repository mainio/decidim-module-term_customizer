# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # The loader class is a middleman that converts the Translation model
    # objects to a flat translation hash that can be directly used in the i18n
    # backend. The main purpose of this class is to add caching possibility for
    # the translation hashes.
    class Loader
      def initialize(resolver)
        @resolver = resolver
      end

      # Converts the translation objects to a flat hash where the keys are
      # the translatable keys used in the i18n backend containing the locales.
      # The values of the hash are the translations for the keys.
      #
      # The final hash looks similar like this:
      # {
      #   en: {
      #     decidim: {
      #       translation: "Term EN"
      #     }
      #   },
      #   fi: {
      #     decidim: {
      #       translation: "Term FI"
      #     }
      #   }
      # }
      #
      # This will also cache the results and fetch the result directly from
      # cache on consequent calls until the cache is expired.
      def translations_hash
        # In order to avoid endless loops with cache logging calling the I18n
        # calling the translation loader, calling cache logging calling I18n
        # (etc.), temporarily mute the cache logging during this call. If the
        # cache logging level is set to `Logger::DEBUG`, it could happen as
        # explained at:
        # https://github.com/mainio/decidim-module-term_customizer/issues/38
        @translations_hash ||= Rails.cache.mute do
          Rails.cache.fetch(cache_key, expires_in: 24.hours) do
            final_hash = {}
            resolver.translations.each do |tr|
              keyparts = [tr.locale] + tr.key.split(".")
              lastkey = keyparts.pop.to_sym

              current = final_hash
              keyparts.each do |key|
                current[key.to_sym] ||= {}
                current = current[key.to_sym]
              end

              current[lastkey] = tr.value
            end
            final_hash
          end
        end
      end

      # Clears the translations cache only for the current context defined by
      # the resolver.
      def clear_cache
        Rails.cache.delete_matched("#{cache_key_base}/*")
      rescue NotImplementedError, NoMethodError
        # Some cache store, such as `ActiveSupport::Cache::MemCacheStore` or
        # `ActiveSupport::Cache::DalliStore` do not support `delete_matched`.
        # Therefore, clear all the possibly existing
        # cache keys manually for each space and component.

        # Clear all the "organization" translation keys.
        Rails.cache.delete(cache_key_base)

        # Iterate over the participatory spaces and their components to manually
        # clear the cached records for all of them.
        Decidim.participatory_space_registry.manifests.each do |manifest|
          manifest.model_class_name.constantize.all.each do |space|
            Rails.cache.delete("#{cache_key_base}/space_#{space.id}")

            next unless space.respond_to?(:components)

            space.components.each do |component|
              Rails.cache.delete(
                "#{cache_key_base}/space_#{space.id}/component_#{component.id}"
              )
            end
          end
        end
      end

      private

      attr_reader :resolver

      def cache_key
        parts = [cache_key_base]
        parts << "space_#{resolver.space.id}" if resolver.space
        parts << "component_#{resolver.component.id}" if resolver.component

        parts.join("/")
      end

      def cache_key_base
        main_key =
          if resolver.organization
            "organization_#{resolver.organization.id}"
          else
            "system"
          end

        "decidim_term_customizer/#{main_key}"
      end
    end
  end
end
