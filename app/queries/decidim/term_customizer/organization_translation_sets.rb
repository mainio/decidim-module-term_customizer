# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # This query class filters all assemblies given an organization.
    class OrganizationTranslationSets < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        columns = [
          "DISTINCT(decidim_term_customizer_translation_sets.id)",
          "name",
          "name->>'#{current_locale}' AS local_name"
        ]

        q = Decidim::TermCustomizer::TranslationSet.joins(:constraints).where(
          decidim_term_customizer_constraints: {
            decidim_organization_id: @organization.id
          }
        ).select(columns.join(","))
        q.order("local_name")
      end

      def count
        query.count(:id)
      end

      private

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
