# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationSetConstraintForm < Decidim::Form
        mimic :constraint

        attribute :subject_manifest, String
        attribute :subject_model, [TermCustomizer::Admin::TranslationSetSubjectForm]
        attribute :deleted, Boolean, default: false

        def to_param
          return id if id.present?

          "constraint-id"
        end

        def map_model(model)
          self.subject_manifest = model.manifest_name

          return unless model.subject

          self.subject_model = [
            TermCustomizer::Admin::TranslationSetSubjectForm.from_model(
              model.subject
            )
          ]
        end

        def subject_type
          return unless subject_form

          subject_form.manifest.try(:model_class_name)
        end

        def subject
          return component if component
          return unless subject_form

          subject_form.subject
        end

        def component
          return unless subject_form

          subject_form.component
        end

        def subject_form
          @subject_form ||= subject_model.find do |sm|
            sm.subject_manifest == subject_manifest
          end
        end
      end
    end
  end
end
