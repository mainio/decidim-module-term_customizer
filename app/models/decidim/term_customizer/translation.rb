# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class Translation < ApplicationRecord
      self.table_name = "decidim_term_customizer_translations"

      belongs_to :translation_set, class_name: "Decidim::TermCustomizer::TranslationSet", foreign_key: "translation_set_id"
      has_many :constraints, through: :translation_set

      validates :key, presence: true
      validates :key, uniqueness: { scope: [:translation_set, :locale] }, unless: -> { key.blank? }

      class << self
        def locale(locale)
          where(locale: locale.to_s)
        end

        def lookup(keys)
          column_name = connection.quote_column_name("key")
          keys = Array(keys).map!(&:to_s)

          namespace = "#{keys.last}#{I18n::Backend::Flatten::FLATTEN_SEPARATOR}%"
          where("#{column_name} IN (?) OR #{column_name} LIKE ?", keys, namespace)
        end

        def available_locales
          Translation.select("DISTINCT locale").to_a.map { |t| t.locale.to_sym }
        end
      end
    end
  end
end
