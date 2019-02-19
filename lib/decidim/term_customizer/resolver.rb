# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Resolver
      def initialize(organization, space, component)
        @organization = organization
        @space = space
        @component = component
      end

      def translations
        @translations ||= Translation.joins(:constraints).where(
          decidim_term_customizer_constraints: {
            id: constraints
          }
        )
      end

      def constraints
        @constraints ||= resolve_query
      end

      private

      attr_reader :organization, :space, :component

      def resolve_query
        query = TermCustomizer::Constraint.where(
          organization: organization,
          subject_type: nil,
          subject_id: nil
        )
        add_space_query(query)
        add_component_query(query)

        query
      end

      def add_space_query(query)
        return unless space

        query.or!(
          TermCustomizer::Constraint.where(
            organization: organization,
            subject: space
          )
        )
        query.or!(
          TermCustomizer::Constraint.where(
            organization: organization,
            subject_type: space.class.name,
            subject_id: nil
          )
        )
      end

      def add_component_query(query)
        return unless component

        query.or!(
          TermCustomizer::Constraint.where(
            organization: organization,
            subject: component
          )
        )
      end
    end
  end
end
