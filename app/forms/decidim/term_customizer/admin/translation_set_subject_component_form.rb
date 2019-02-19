# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationSetSubjectComponentForm < Decidim::Form
        attribute :subject_id, Integer
        attribute :component_id, Integer
      end
    end
  end
end
