# frozen_string_literal: true

shared_examples "translation validatable" do
  context "when key is empty" do
    let(:key) { nil }

    it { is_expected.to be_invalid }
  end

  context "when key is incorrect format" do
    context "with spaces" do
      let(:key) { "incorrect format key" }

      it { is_expected.to be_invalid }
    end

    context "with uppercase characters" do
      let(:key) { "Translation.Key" }

      it { is_expected.to be_invalid }
    end

    context "with blank character at the beginning" do
      let(:key) { " translation.key" }

      it { is_expected.to be_invalid }
    end

    context "with blank character at the end" do
      let(:key) { "translation.key " }

      it { is_expected.to be_invalid }
    end

    context "with a dot character at the beginning" do
      let(:key) { ".translation.key" }

      it { is_expected.to be_invalid }
    end

    context "with a dot character at the end" do
      let(:key) { "translation.key." }

      it { is_expected.to be_invalid }
    end
  end

  context "when key already exists with the same locale and translation set" do
    before do
      create(
        :translation,
        translation_set: translation_set,
        locale: locale,
        key: key
      )
    end

    it { is_expected.to be_invalid }
  end
end
