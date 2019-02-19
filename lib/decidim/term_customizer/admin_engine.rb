# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::TermCustomizer::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :translation_sets, path: :sets, except: [:show] do
          resources :translations, except: [:show]
        end

        root to: "translation_sets#index"
      end

      initializer "decidim_term_customizer.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::TermCustomizer::AdminEngine, at: "/admin/term_customizer", as: "decidim_admin_term_customizer"
        end
      end

      initializer "decidim_term_customizer.admin_assets" do |app|
        app.config.assets.precompile += %w(translation_sets_admin_manifest.js)
      end

      initializer "decidim_term_customizer.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.item I18n.t("menu.term_customizer", scope: "decidim.term_customizer"),
                    decidim_admin_term_customizer.translation_sets_path,
                    icon_name: "text",
                    position: 7.1,
                    active: :inclusive,
                    if: allowed_to?(:update, :organization, organization: current_organization)
        end
      end
    end
  end
end
