# frozen_string_literal: true

require_relative "term_customizer/version"
require_relative "term_customizer/engine"
require_relative "term_customizer/admin"
require_relative "term_customizer/admin_engine"

module Decidim
  module TermCustomizer
    autoload :I18nBackend, "decidim/term_customizer/i18n_backend"
    autoload :Import, "decidim/term_customizer/import"
    autoload :Loader, "decidim/term_customizer/loader"
    autoload :PluralFormsForm, "decidim/term_customizer/plural_forms_form"
    autoload :PluralFormsManager, "decidim/term_customizer/plural_forms_manager"
    autoload :Resolver, "decidim/term_customizer/resolver"
    autoload :TranslationDirectory, "decidim/term_customizer/translation_directory"
    autoload :TranslationImportCollection, "decidim/term_customizer/translation_import_collection"
    autoload :TranslationParser, "decidim/term_customizer/translation_parser"
    autoload :TranslationSerializer, "decidim/term_customizer/translation_serializer"
    autoload :TranslationStore, "decidim/term_customizer/translation_store"

    EMPTY_HASH = {}.freeze

    class << self
      attr_accessor :loader
    end
  end
end
