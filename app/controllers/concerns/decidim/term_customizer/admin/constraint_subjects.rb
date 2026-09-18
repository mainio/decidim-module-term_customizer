# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # Resolves the participatory spaces and the components that can be
      # selected as the subject of a translation set constraint.
      #
      # The manifest is always looked up from the participatory space registry
      # so that a request parameter is never turned into an arbitrary constant
      # and the spaces are always scoped to the current organization.
      module ConstraintSubjects
        extend ActiveSupport::Concern

        included do
          include Decidim::TranslatableAttributes

          helper_method :constraint_space_options, :constraint_space, :constraint_component_options
        end

        private

        # The participatory space manifest matching the given name, or nil when
        # there is no such manifest registered.
        def constraint_manifest(manifest_name)
          return if manifest_name.blank?

          Decidim.participatory_space_manifests.find do |manifest|
            manifest.name.to_s == manifest_name.to_s
          end
        end

        # All the spaces of the given manifest as select options. Memoized
        # because the same list is rendered once per constraint.
        def constraint_space_options(manifest)
          @constraint_space_options ||= {}
          @constraint_space_options[manifest.name] ||=
            manifest.model_class_name.constantize.where(organization: current_organization).map do |space|
              [translated_attribute(space.title), space.id]
            end
        end

        # The space of the given manifest within the current organization, or
        # nil when it does not exist.
        def constraint_space(manifest_name, space_id)
          @constraint_spaces ||= {}
          key = [manifest_name.to_s, space_id.to_s]
          return @constraint_spaces[key] if @constraint_spaces.has_key?(key)

          @constraint_spaces[key] = constraint_space_relation(manifest_name, space_id)&.find_by(id: space_id)
        end

        # The components of the given space as select options. Spaces that do
        # not have components at all report an empty list.
        def constraint_component_options(space)
          return [] unless space.respond_to?(:components)

          # The identifier alone is not unique, two spaces of different
          # manifests can share it.
          @constraint_component_options ||= {}
          @constraint_component_options[[space.class.name, space.id]] ||= space.components.map do |component|
            [translated_attribute(component.name), component.id]
          end
        end

        def constraint_space_relation(manifest_name, space_id)
          return if space_id.blank?

          manifest = constraint_manifest(manifest_name)
          return if manifest.blank?

          manifest.model_class_name.constantize.where(organization: current_organization)
        end
      end
    end
  end
end
