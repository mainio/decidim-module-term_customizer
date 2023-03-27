# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Context::ControllerContext do
  let(:subject) { described_class.new(data) }
  let(:data) { { headers: headers } }
  let(:headers) { double }
  let(:controller) { double }
  let(:organization) { create(:organization) }

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

  context "with participatory process group defined in the controller" do
    let(:env) do
      {
        "action_controller.instance" => controller,
        "decidim.current_organization" => organization
      }
    end

    let(:process_group) { create(:participatory_process_group, organization: organization) }

    before do
      allow(controller).to receive(:params).and_return({ id: process_group.id })
      allow(controller).to receive(:instance_of?).with(Decidim::ParticipatoryProcesses::ParticipatoryProcessGroupsController).and_return(true)
    end

    it "resolves the participatory space as the participatory_process group" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to eq(process_group)
      expect(subject.component).to be_nil
    end
  end
end
