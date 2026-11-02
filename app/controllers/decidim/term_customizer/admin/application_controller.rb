# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # This controller is the abstract class from which all other controllers
      # of this engine inherit.
      class ApplicationController < Decidim::Admin::ApplicationController
        # rubocop:disable Decidim/EnforcePermissionTo
        def permission_class_chain
          [Decidim::TermCustomizer::Admin::Permissions] + super
        end
        # rubocop:enable Decidim/EnforcePermissionTo
      end
    end
  end
end
