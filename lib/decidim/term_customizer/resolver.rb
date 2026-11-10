# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Resolver
      attr_reader :organization, :space, :component

      def initialize(organization, space, component)
        @organization = organization
        @space = space
        @component = component
      end

      def translations
        @translations ||= resolve_translations_query
      end

      def constraints
        @constraints ||= resolve_constraints_query
      end

      private

      def resolve_translations_query
        query = translations_base_query
        translations_add_constraints_query(query)

        query
      end

      def translations_base_query
        # All translations without any constraints
        Translation.where.not(id: Translation.joins(:constraints))
      end

      def translations_add_constraints_query(query)
        return unless constraints

        query.or!(
          Translation.where(
            id: Translation.joins(:constraints).where(
              decidim_term_customizer_constraints: {
                id: constraints
              }
            )
          )
        )
      end

      def resolve_constraints_query
        return nil unless organization

        query = constraints_base_query
        constraints_add_organization_query(query)
        constraints_add_space_query(query)
        constraints_add_component_query(query)

        query
      end

      def constraints_base_query
        # All constraints that are NOT attached with any organization
        TermCustomizer::Constraint.where(organization: nil)
      end

      def constraints_add_organization_query(query)
        return unless organization

        query.or!(
          TermCustomizer::Constraint.where(
            organization:,
            subject_type: nil,
            subject_id: nil
          )
        )
      end

      def constraints_add_space_query(query)
        return unless space

        query.or!(
          TermCustomizer::Constraint.where(
            organization:,
            subject: space
          )
        )
        query.or!(
          TermCustomizer::Constraint.where(
            organization:,
            subject_type: space.class.name,
            subject_id: nil
          )
        )
      end

      def constraints_add_component_query(query)
        return unless component

        query.or!(
          TermCustomizer::Constraint.where(
            organization:,
            subject: component
          )
        )
      end
    end
  end
end
