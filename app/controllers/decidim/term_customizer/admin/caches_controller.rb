# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class CachesController < TermCustomizer::Admin::ApplicationController
        def index
          enforce_permission_to :update, :organization

          redirect_to translation_sets_path
        end

        def clear
          enforce_permission_to :update, :organization

          TermCustomizer.loader.clear_cache
          flash[:notice] = I18n.t("caches.clear.success", scope: "decidim.term_customizer.admin")

          redirect_to translation_sets_path
        end
      end
    end
  end
end
