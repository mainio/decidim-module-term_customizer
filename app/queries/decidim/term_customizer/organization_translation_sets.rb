# frozen_string_literal: true

module Decidim
  module TermCustomizer
    # This query class filters all assemblies given an organization.
    class OrganizationTranslationSets < Rectify::Query
      def initialize(organization)
        @organization = organization
      end

      def query
        Decidim::TermCustomizer::TranslationSet.joins(:constraints).where(
          decidim_term_customizer_constraints: {
            decidim_organization_id: @organization.id
          }
        ).distinct
      end
    end
  end
end
