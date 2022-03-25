# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Constraint < TermCustomizer::ApplicationRecord
      self.table_name = "decidim_term_customizer_constraints"

      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"
      belongs_to :translation_set, class_name: "Decidim::TermCustomizer::TranslationSet"
      belongs_to :subject, optional: true, polymorphic: true
      has_many :translations, through: :translation_set

      def component
        subject if subject.is_a?(Decidim::Component)
      end

      def space
        return component.participatory_space if component

        subject
      end

      def manifest
        space_class = space ? space.class.name : subject_type

        Decidim.participatory_space_manifests.find do |manifest|
          manifest.model_class_name == space_class
        end
      end

      def manifest_name
        manifest.try(:name)
      end
    end
  end
end
