# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationSetSubjectForm < Decidim::Form
        attribute :subject_manifest, String
        attribute :subject_id, Integer
        attribute :component_model, [TermCustomizer::Admin::TranslationSetSubjectComponentForm]

        def map_model(model)
          component = model if model.is_a?(Decidim::Component)
          subject = if component
                      model.participatory_space
                    else
                      model
                    end

          self.subject_manifest = Decidim.participatory_space_manifests.find do |m|
            m.model_class_name == subject.class.name
          end.try(:name)
          self.subject_id = subject.id

          return unless component

          self.component_model = [
            TermCustomizer::Admin::TranslationSetSubjectComponentForm.from_params(
              subject_id: subject.id,
              component_id: component.id
            )
          ]
        end

        def subject
          return unless manifest

          @subject ||= manifest.model_class_name.constantize.find_by(id: subject_id)
        end

        def component
          return unless component_form
          return unless subject
          return unless subject.respond_to?(:components)

          subject.components.find_by(id: component_form.component_id)
        end

        def manifest
          @manifest ||= Decidim.participatory_space_manifests.find do |m|
            m.name == subject_manifest.to_sym
          end
        end

        def component_form
          @component_form ||= component_model.find do |cm|
            cm.subject_id == subject_id
          end
        end
      end
    end
  end
end
