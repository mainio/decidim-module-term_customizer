# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Translation < TermCustomizer::ApplicationRecord
      self.table_name = "decidim_term_customizer_translations"

      belongs_to :translation_set, class_name: "Decidim::TermCustomizer::TranslationSet", foreign_key: "translation_set_id"
      has_many :constraints, through: :translation_set

      validates :locale, presence: true
      validates :key, presence: true
      validates :key, format: { with: %r{\A([a-z0-9_/\?\-]+\.)*[a-z0-9_/\?\-]+\z} }, unless: -> { key.blank? }
      validates :key, uniqueness: { scope: [:translation_set, :locale] }, unless: -> { key.blank? }

      class << self
        def available_locales
          Translation.select("DISTINCT locale").to_a.map { |t| t.locale.to_sym }
        end
      end
    end
  end
end
