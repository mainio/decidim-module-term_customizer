# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/term_customizer/version"

gem "decidim", ">= 0.20.0", Decidim::TermCustomizer::DECIDIM_VERSION
gem "decidim-term_customizer", path: "."

gem "bootsnap", "~> 1.4"
gem "puma", "~> 3.12"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "dalli", "~> 2.7", ">= 2.7.10" # For testing MemCacheStore
  gem "decidim-consultations", ">= 0.20.0", Decidim::TermCustomizer::DECIDIM_VERSION
  gem "decidim-dev", ">= 0.20.0", Decidim::TermCustomizer::DECIDIM_VERSION
end

group :development do
  gem "faker", "~> 1.9"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "codecov", require: false
end

# Remediate CVE-2019-5420
gem "railties", ">= 5.2.2.1"
