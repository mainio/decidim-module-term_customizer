# frozen_string_literal: true

module Decidim
  module TermCustomizer
    module Admin
      class TranslationForm < Decidim::Form
        include TranslatableAttributes

        mimic :translation

        delegate :translation_set, to: :context, prefix: false, allow_nil: true

        attribute :key, String
        translatable_attribute :value, String

        validates :key, presence: true
        validates :key, format: { with: %r{\A([a-z0-9_/\?\-]+\.)*[a-z0-9_/\?\-]+\z} }, unless: -> { key.blank? }
        validates :value, translatable_presence: true
        validate :key_uniqueness

        def map_model(model)
          self.value = Hash[Decidim::TermCustomizer::Translation.where(
            translation_set: model.translation_set,
            key: model.key
          ).map do |translation|
            [translation.locale, translation.value]
          end]
        end

        def key_uniqueness
          errors.add(:key, :taken) if translation_set && translation_set.translations.where(
            locale: I18n.locale,
            key: key
          ).where.not(id: id).exists?
        end
      end
    end
  end
end
