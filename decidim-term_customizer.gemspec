# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/term_customizer/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-term_customizer"
  spec.version = Decidim::TermCustomizer::VERSION
  spec.authors = ["Antti Hukkanen"]
  spec.email = ["antti.hukkanen@mainiotech.fi"]

  spec.summary = "Provides possibility to customize Decidim's localized terms."
  spec.description = "Adds a UI to customize the terms and limit the customizations to specific places."
  spec.homepage = "https://github.com/mainio/decidim-module-term_customizer"
  spec.license = "AGPL-3.0"

  spec.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE-AGPLv3.txt",
    "Rakefile",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::TermCustomizer::DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::TermCustomizer::DECIDIM_VERSION
  spec.add_dependency "spreadsheet", "~> 1.2"

  spec.add_development_dependency "dalli", "~> 2.7", ">= 2.7.10" # For testing MemCacheStore
  spec.add_development_dependency "decidim-consultations", Decidim::TermCustomizer::DECIDIM_VERSION
  spec.add_development_dependency "decidim-dev", Decidim::TermCustomizer::DECIDIM_VERSION
  spec.add_development_dependency "decidim-participatory_processes", Decidim::TermCustomizer::DECIDIM_VERSION
  spec.add_development_dependency "decidim-proposals", Decidim::TermCustomizer::DECIDIM_VERSION
end
