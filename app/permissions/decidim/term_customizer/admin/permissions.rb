# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          return permission_action unless permission_action.scope == :admin

          unless user.admin?
            disallow!
            return permission_action
          end

          if read_admin_dashboard_action?
            allow!
            return permission_action
          end

          allowed_translation_set_action?
          allowed_translation_action?
          allowed_translation_bulk_action?

          permission_action
        end

        private

        def translation_set
          @translation_set ||= context.fetch(:translation_set, nil)
        end

        def translation
          @translation ||= context.fetch(:translation, nil)
        end

        def allowed_translation_set_action?
          return false unless permission_action.subject == :translation_set

          case permission_action.action
          when :create, :read
            allow!
          when :update, :destroy, :import, :export
            toggle_allow(translation_set.present?)
          end
        end

        def allowed_translation_action?
          return false unless permission_action.subject == :translation

          case permission_action.action
          when :create, :read
            allow!
          when :update, :destroy
            toggle_allow(translation.present?)
          end
        end

        def allowed_translation_bulk_action?
          return false unless permission_action.subject == :translations

          case permission_action.action
          when :destroy
            toggle_allow(translation_set.present?)
          end
        end

        def read_admin_dashboard_action?
          permission_action.action == :read &&
            permission_action.subject == :admin_dashboard
        end
      end
    end
  end
end
