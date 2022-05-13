# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::PluralFormsManager do
  let(:locales) { [:en, :fi, :sv] }
  let(:plural_keys) { [:zero, :one, :few, :other] }
  let(:organization) { create(:organization, available_locales: locales) }
  let(:translation_set) { create(:translation_set, organization: organization) }
  let(:subject) { described_class.new(organization) }

  before do
    I18n.available_locales = locales
  end

  # The test cases include also the `:few` key which is one of the default
  # plural keys configured for the plural forms manager. However, this key does
  # not exist in the base translation to also test cases when the base
  # translation uses a plural format which does not have a corresponding source
  # translation.
  [:zero, :one, :few, :other].each do |plural_key|
    it "creates all plural forms for the plural form #{plural_key}" do
      base_key = "test.plural"
      key = "#{base_key}.#{plural_key}"
      base = create_translations(key, :en)

      subject.fill!(base)

      existing = {}.tap do |hash|
        translation_set.translations.order(:key).each do |tr|
          hash[tr.locale.to_sym] ||= []
          hash[tr.locale.to_sym] << tr.key
        end
      end

      other_keys = [:one, :other, :zero].map do |other_key|
        next if other_key == plural_key

        "#{base_key}.#{other_key}"
      end.reject(&:nil?)

      # Note that the `:few` key does not exist in the source translation which
      # means that in case we add translations for that, all the plural formats
      # are added also for the base translation.
      expected_amount = plural_key == :few ? 10 : 7
      expect(translation_set.translations.count).to eq(expected_amount)
      expect(existing).to include(
        en: ([key] + other_keys).sort,
        fi: other_keys,
        sv: other_keys
      )
    end

    it "destroys all plural forms for the plural form #{plural_key}" do
      base_key = "test.plural"
      key = "#{base_key}.#{plural_key}"
      base = create_translations(key, :en)
      create_translations(key, :fi, :sv)

      # Create the "other" plural forms that have available translations.
      # These are the ones that should be destroyed, not the one that we are
      # calling the destroy! method for.
      [:zero, :one, :other].each do |other_key|
        next if other_key == plural_key

        create_translations("#{base_key}.#{other_key}", *locales)
      end

      # Add a couple of other translations
      create_translations("city", *locales)
      create_translations("translation", *locales)

      subject.destroy!(base)

      # Should keep the base translation itself and the extra translations that
      # are not plural forms for the base translation.
      expect(translation_set.translations.count).to eq(3 * locales.length)
    end
  end

  it "does not create plural forms for a non-plural form translation" do
    base = create_translations("city", *locales)

    subject.fill!(base)

    expect(translation_set.translations.count).to eq(3)
  end

  context "when specific plural keys are configured" do
    before do
      described_class.plural_keys = [:one, :other]
    end

    it "adds only the configured plural keys" do
      base_key = "test.plural"
      key = "#{base_key}.one"
      base = create_translations(key, :en)
      create_translations(key, :fi, :sv)

      subject.fill!(base)

      existing = {}.tap do |hash|
        translation_set.translations.each do |tr|
          hash[tr.locale.to_sym] ||= []
          hash[tr.locale.to_sym] << tr.key
        end
      end

      expect(translation_set.translations.count).to eq(6)
      expect(existing).to include(
        en: ["test.plural.one", "test.plural.other"],
        fi: ["test.plural.one", "test.plural.other"],
        sv: ["test.plural.one", "test.plural.other"]
      )
    end
  end

  def create_translations(key, *locales)
    locales.map do |locale|
      create(
        :translation,
        translation_set: translation_set,
        key: key,
        value: "Translation",
        locale: locale
      )
    end
  end
end
