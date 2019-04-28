# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build :user, :admin, organization: organization }
  let(:organization) { build :organization }
  let(:current_component) { create(:plan_component) }
  let(:translation_set) { nil }
  let(:translation) { nil }
  let(:context) do
    {
      translation_set: translation_set,
      translation: translation
    }
  end
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  describe "translation set creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :translation_set }
    end

    it { is_expected.to eq true }
  end

  describe "translation set reading" do
    let(:action) do
      { scope: :admin, action: :read, subject: :translation_set }
    end

    let(:translation_set) { create :translation_set, organization: organization }

    it { is_expected.to eq true }
  end

  describe "translation set editing" do
    let(:action) do
      { scope: :admin, action: :update, subject: :translation_set }
    end

    let(:translation_set) { create :translation_set, organization: organization }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end

  describe "translation set destroying" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :translation_set }
    end

    let(:translation_set) { create :translation_set, organization: organization }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end

  describe "translation set exporting" do
    let(:action) do
      { scope: :admin, action: :export, subject: :translation_set }
    end

    let(:translation_set) { create :translation_set, organization: organization }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end

  describe "translation creation" do
    let(:action) do
      { scope: :admin, action: :create, subject: :translation }
    end

    it { is_expected.to eq true }
  end

  describe "translation reading" do
    let(:action) do
      { scope: :admin, action: :read, subject: :translation }
    end

    let(:set) { create :translation_set, organization: organization }
    let(:translation) { create :translation, translation_set: set }

    it { is_expected.to eq true }
  end

  describe "translation editing" do
    let(:action) do
      { scope: :admin, action: :update, subject: :translation }
    end

    let(:set) { create :translation_set, organization: organization }
    let(:translation) { create :translation, translation_set: set }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end

  describe "translation destroying" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :translation }
    end

    let(:set) { create :translation_set, organization: organization }
    let(:translation) { create :translation, translation_set: set }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end

  describe "translations importing" do
    let(:action) do
      { scope: :admin, action: :import, subject: :translation_set }
    end

    let(:translation_set) { create :translation_set, organization: organization }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end

  describe "translations bulk destroying" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :translations }
    end

    let(:translation_set) { create :translation_set, organization: organization }

    context "when everything is OK" do
      it { is_expected.to eq true }
    end
  end
end
