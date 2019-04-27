# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Import
      autoload :ImporterFactory, "decidim/term_customizer/import/importer_factory"
      autoload :Importer, "decidim/term_customizer/import/importer"
      autoload :Parser, "decidim/term_customizer/import/parser"
      autoload :Readers, "decidim/term_customizer/import/readers"
    end
  end
end
