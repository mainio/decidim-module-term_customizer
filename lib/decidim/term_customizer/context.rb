# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Context
      autoload :Base, "decidim/term_customizer/context/base"
      autoload :ControllerContext, "decidim/term_customizer/context/controller_context"
      autoload :JobContext, "decidim/term_customizer/context/job_context"
    end
  end
end
