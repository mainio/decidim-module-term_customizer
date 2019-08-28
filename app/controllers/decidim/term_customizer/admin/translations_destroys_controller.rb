# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationsDestroysController < Admin::ApplicationController
        helper_method :set

        before_action :set_form

        def new
          enforce_permission_to :destroy, :translations, translation_set: set
        end

        def destroy
          enforce_permission_to :destroy, :translations, translation_set: set

          Admin::DestroyTranslations.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("translations_destroys.destroy.success", scope: "decidim.term_customizer.admin")
              redirect_to translation_set_translations_path(set)
            end

            on(:invalid) do
              if @form.translations.count < 1
                flash[:alert] = I18n.t("translations_destroys.destroy.error", scope: "decidim.term_customizer.admin")
                redirect_to translation_set_translations_path(set)
              else
                flash.now[:alert] = I18n.t("translations_destroys.destroy.error", scope: "decidim.term_customizer.admin")
                render action: "new"
              end
            end
          end
        end

        private

        def set_form
          @form = form(Admin::TranslationsDestroyForm).from_params(
            params
          ).with_context(
            current_organization: current_organization,
            translation_set: set
          )
        end

        def translation_set
          @translation_set ||= OrganizationTranslationSets.new(
            current_organization
          ).query.find(params[:translation_set_id])
        end

        alias set translation_set
      end
    end
  end
end
