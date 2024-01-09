# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Context::ControllerContext do
  subject { described_class.new(data) }

  let(:data) { { headers: } }
  let(:headers) { double }
  let(:controller) { double }
  let(:organization) { double }

  before do
    allow(headers).to receive(:env).and_return(env)
  end

  context "with current organization defined in the environment" do
    let(:env) do
      {
        "action_controller.instance" => controller,
        "decidim.current_organization" => organization
      }
    end

    it "resolves the organization" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end

  context "with participatory space defined in the environment" do
    let(:space) { double }

    let(:env) do
      {
        "action_controller.instance" => controller,
        "decidim.current_organization" => organization,
        "decidim.current_participatory_space" => space
      }
    end

    it "resolves the participatory space" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be_nil
    end
  end

  context "with participatory space defined in the controller" do
    let(:env) do
      {
        "action_controller.instance" => controller,
        "decidim.current_organization" => organization
      }
    end

    context "when the participatory space exists" do
      let(:space) { double }

      before do
        allow(controller).to receive(:current_participatory_space).and_return(space)
      end

      it "resolves the participatory space" do
        expect(subject.organization).to be(organization)
        expect(subject.space).to be(space)
        expect(subject.component).to be_nil
      end
    end

    context "when the method raises an ActiveRecord::RecordNotFound" do
      before do
        allow(controller).to receive(:current_participatory_space).and_raise(ActiveRecord::RecordNotFound)
      end

      it "recovers from the error" do
        expect(subject.organization).to be(organization)
        expect(subject.space).to be_nil
        expect(subject.component).to be_nil
      end
    end
  end

  context "with component defined in the environment" do
    let(:space) { double }
    let(:component) { double }

    let(:env) do
      {
        "action_controller.instance" => controller,
        "decidim.current_organization" => organization,
        "decidim.current_participatory_space" => space,
        "decidim.current_component" => component
      }
    end

    it "resolves the organization" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be(component)
    end
  end
end
