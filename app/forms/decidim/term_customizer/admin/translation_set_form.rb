# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationSetForm < Decidim::Form
        include TranslatableAttributes

        mimic :translation_set

        translatable_attribute :name, String
        attribute :constraints, [TermCustomizer::Admin::TranslationSetConstraintForm]

        validates :name, translatable_presence: true
      end
    end
  end
end
