# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user
        return Decidim::TermCustomizer::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        permission_action
      end
    end
  end
end
