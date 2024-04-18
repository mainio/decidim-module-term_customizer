# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::TermCustomizer::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :translation_sets, path: :sets, except: [:show] do
          member do
            post :duplicate
          end

          resources :translations, except: [:show] do
            collection do
              post :export
              get :import, action: :new_import
              post :import
              resource :translations_destroy, only: [:new, :destroy]
            end
          end
          resources :add_translations, only: [:index, :create] do
            collection do
              get :search
            end
          end
        end

        resources :caches, only: [:index] do
          collection do
            delete :clear
          end
        end

        root to: "translation_sets#index"
      end

      initializer "decidim_term_customizer.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::TermCustomizer::AdminEngine, at: "/admin/term_customizer", as: "decidim_admin_term_customizer"
        end
      end

      initializer "decidim_term_customizer.register_icons" do |_app|
        Decidim.icons.register(name: "Decidim::TermCustomizer", icon: "translate", category: "system", description: "Term Customizer", engine: :admin)
        Decidim.icons.register(name: "git-branch-line", icon: "git-branch-line", category: "system", description: "fork icon", engine: :admin)
      end

      initializer "decidim_term_customizer.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item(
            :term_customizer,
            I18n.t("menu.term_customizer", scope: "decidim.term_customizer"),
            decidim_admin_term_customizer.translation_sets_path,
            icon_name: "Decidim::TermCustomizer",
            position: 7.1,
            active: :inclusive,
            if: allowed_to?(:update, :organization, organization: current_organization)
          )
        end

        Decidim.menu :term_customizer_translation_sets_menu do |menu|
          menu.add_item(
            :term_customizer_translation_sets,
            I18n.t("menu.translation_set", scope: "decidim.term_customizer"),
            decidim_admin_term_customizer.translation_set_translations_path,
            active: is_active_link?(decidim_admin_term_customizer.translation_set_translations_path) ||
              is_active_link?(decidim_admin_term_customizer.translation_set_add_translations_path)
          )
        end
      end
    end
  end
end
