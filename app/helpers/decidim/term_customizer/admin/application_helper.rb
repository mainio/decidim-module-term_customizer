# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      module ApplicationHelper
        def tabs_id_for_constraint(constraint)
          "constraint_#{constraint.to_param}"
        end
      end
    end
  end
end
