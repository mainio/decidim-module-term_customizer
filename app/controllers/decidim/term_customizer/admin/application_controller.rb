# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      # This controller is the abstract class from which all other controllers
      # of this engine inherit.

      class ApplicationController < Decidim::Admin::ApplicationController
        def permission_class_chain
          [Decidim::TermCustomizer::Admin::Permissions] + super
        end
      end
    end
  end
end
