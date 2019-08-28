# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module PluralFormsForm
      private

      def create_plural_forms(translations)
        plural_forms_manager.fill!(translations)
      end

      def destroy_plural_forms(translations)
        plural_forms_manager.destroy!(translations)
      end

      def plural_forms_manager
        @plural_forms_manager ||= TermCustomizer::PluralFormsManager.new(
          form.current_organization
        )
      end
    end
  end
end
