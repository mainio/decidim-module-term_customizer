# frozen_string_literal: true

module Decidim
  module TermCustomizer
    class TranslationSet < ApplicationRecord
      self.table_name = "decidim_term_customizer_translation_sets"

      has_many :translations,
               class_name: "Decidim::TermCustomizer::Translation",
               foreign_key: :translation_set_id,
               dependent: :destroy

      has_many :constraints,
               class_name: "Decidim::TermCustomizer::Constraint",
               foreign_key: :translation_set_id,
               dependent: :destroy
    end
  end
end
