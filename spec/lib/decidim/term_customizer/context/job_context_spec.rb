# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Context::JobContext do
  subject { described_class.new(data) }

  let(:data) { { job: job } }
  let(:job) { double }
  let(:organization) { create(:organization) }
  let(:arguments) { [organization] }

  before do
    allow(job).to receive(:arguments).and_return(arguments)
  end

  context "with organization passed in the arguments" do
    let(:arguments) { [organization] }

    it "resolves the organization" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end

  context "with object having an organization passed in the arguments" do
    let(:obj) { double }
    let(:arguments) { [obj] }

    before do
      allow(obj).to receive(:organization).and_return(organization)
    end

    it "resolves the organization" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end

  context "with user passed in the arguments" do
    let(:user) { create(:user) }
    let(:arguments) { [user] }

    it "resolves the user's organization" do
      expect(subject.organization).to be(user.organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end

  context "with participatory process passed in the arguments" do
    let(:space) { create(:participatory_process, organization: organization) }
    let(:arguments) { [organization, space] }

    it "resolves the participatory space" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be_nil
    end
  end

  context "with object having a participatory process passed in the arguments" do
    let(:space) { create(:participatory_process, organization: organization) }
    let(:obj) { double }
    let(:arguments) { [organization, obj] }

    before do
      allow(obj).to receive(:participatory_space).and_return(space)
    end

    it "resolves the participatory space" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be_nil
    end
  end

  context "with component passed in the arguments" do
    let(:space) { create(:participatory_process, organization: organization) }
    let(:component) do
      create(:component, manifest_name: :proposals, participatory_space: space)
    end
    let(:arguments) { [component] }

    it "resolves the participatory space" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be(component)
    end
  end

  context "with component and space passed in the arguments" do
    let(:other_space) { create(:participatory_process, organization: organization) }
    let(:space) { create(:participatory_process, organization: organization) }
    let(:component) do
      create(:component, manifest_name: :proposals, participatory_space: space)
    end
    let(:arguments) { [other_space, component] }

    it "resolves the participatory space based on the component" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be(component)
    end
  end

  context "with organization and space passed in the arguments" do
    let(:other_organization) { create(:organization) }
    let(:space) { create(:participatory_process, organization: organization) }
    let(:arguments) { [other_organization, space] }

    it "resolves the participatory space based on the component" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be_nil
    end
  end

  context "with object having a component passed in the arguments" do
    let(:space) { create(:participatory_process, organization: organization) }
    let(:component) do
      create(:component, manifest_name: :proposals, participatory_space: space)
    end
    let(:obj) { double }
    let(:arguments) { [obj] }

    before do
      allow(obj).to receive(:component).and_return(component)
    end

    it "resolves the participatory space" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be(space)
      expect(subject.component).to be(component)
    end
  end

  context "with object having arguments passed as Hash" do
    let(:arguments) { [args: [organization]] }

    it "resolves the organization" do
      expect(subject.organization).to be(organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end

  context "with a list of arguments" do
    let(:user) { create(:user) }
    let(:arguments) { ["Decidim::DecidimDeviseMailer", "reset_password_instructions", "deliver_now", { args: [user] }] }

    it "resolves the user's organization" do
      expect(subject.organization).not_to be(organization)
      expect(subject.organization).to be(user.organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end

  context "with a resource that does not contain args" do
    let(:user) { create(:user) }
    let(:arguments) { ["Decidim::DecidimDeviseMailer", "reset_password_instructions", "deliver_now", user] }

    it "resolves the user's organization" do
      expect(arguments).not_to respond_to(:args)
      expect(subject.organization).not_to be(organization)
      expect(subject.organization).to be(user.organization)
      expect(subject.space).to be_nil
      expect(subject.component).to be_nil
    end
  end
end
