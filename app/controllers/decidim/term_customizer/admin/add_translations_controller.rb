# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class AddTranslationsController < TermCustomizer::Admin::ApplicationController
        helper_method :set

        def index
          enforce_permission_to :read, :translation

          @form = form(TranslationKeyImportForm).from_model(Translation.new)
        end

        def create
          enforce_permission_to :create, :translation
          @form = form(TranslationKeyImportForm).from_params(
            params,
            current_organization: current_organization,
            translation_set: set
          )

          ImportTranslationKeys.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("translations.create.success", scope: "decidim.term_customizer.admin")
              redirect_to translation_set_translations_path(set)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("translations.create.error", scope: "decidim.term_customizer.admin")
              render action: "index"
            end
          end
        end

        def search
          enforce_permission_to :read, :translation
          return render json: [] unless params.has_key?(:term)

          directory = TranslationDirectory.new(current_locale)
          translations = directory.translations_search(params[:term])
          translations.reject! { |k| reject_keys.include?(k) }

          render json: translations.map { |k, v| [k, ERB::Util.html_escape(v)] }
        end

        private

        def translation_set
          @translation_set ||= OrganizationTranslationSets.new(
            current_organization
          ).query.find(params[:translation_set_id])
        end

        def reject_keys
          @reject_keys ||= (request_keys + existing_keys).uniq
        end

        def request_keys
          return params[:keys] if params.has_key?(:keys)

          []
        end

        def existing_keys
          SetTranslations.new(set).pluck(:key).uniq
        end

        alias set translation_set
      end
    end
  end
end
