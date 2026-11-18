# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # Returns the components of a single participatory space so that the
      # translation set constraint fields can load them when the space is
      # selected instead of rendering every component of every space of the
      # organization within the form.
      class ConstraintComponentsController < TermCustomizer::Admin::ApplicationController
        include Decidim::TermCustomizer::Admin::ConstraintSubjects

        def index
          enforce_permission_to :read, :translation_set

          return render json: { error: "not_found" }, status: :not_found if space.blank?

          render json: {
            manifest: params[:manifest].to_s,
            space_id: space.id,
            components_supported: space.respond_to?(:components),
            label: component_label,
            components: constraint_component_options(space).map { |(name, id)| { id:, name: } }
          }
        end

        private

        def space
          @space ||= constraint_space(params[:manifest], params[:space_id])
        end

        def component_label
          TranslationSetConstraintForm.human_attribute_name(:component_id)
        end
      end
    end
  end
end
