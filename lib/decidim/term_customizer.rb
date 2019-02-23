# frozen_string_literal: true

require_relative "term_customizer/version"
require_relative "term_customizer/engine"
require_relative "term_customizer/admin"
require_relative "term_customizer/admin_engine"

module Decidim
  module TermCustomizer
    autoload :I18nBackend, "decidim/term_customizer/i18n_backend"
    autoload :Resolver, "decidim/term_customizer/resolver"
    autoload :TranslationDirectory, "decidim/term_customizer/translation_directory"
    autoload :TranslationStore, "decidim/term_customizer/translation_store"

    EMPTY_HASH = {}.freeze

    class << self
      attr_accessor :resolver
    end
  end
end
