# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::Resolver do
  subject { described_class.new(organization, space, component) }

  let(:organization) { create(:organization) }
  let(:space) { nil }
  let(:component) { nil }
  let(:set) { create(:translation_set) }
  let(:constraint) { set.constraints.create!(organization:) }

  context "with organization" do
    let(:other_organization) { create(:organization) }
    let!(:other_set) { create(:translation_set) }
    let!(:other_constraint) { other_set.constraints.create!(organization: other_organization) }

    describe "#constraints" do
      it "returns correct constraints" do
        expect(subject.constraints).to contain_exactly(constraint)
      end
    end

    describe "#translations" do
      let(:translations) { create_list(:translation, 10, translation_set: set) }
      let!(:other_translations) { create_list(:translation, 10, translation_set: other_set) }

      it "returns correct translations" do
        expect(subject.translations).to match_array(translations)
      end
    end
  end

  context "with participatory process" do
    let(:space) { create(:participatory_process, organization:) }
    let(:other_space) { create(:participatory_process, organization:) }
    let(:other_set) { create(:translation_set) }

    let(:constraint) do
      set.constraints.create!(
        organization:,
        subject: space
      )
    end
    let!(:other_constraint) do
      other_set.constraints.create!(
        organization:,
        subject: other_space
      )
    end

    describe "#constraints" do
      it "returns correct constraints" do
        expect(subject.constraints).to contain_exactly(constraint)
      end
    end

    describe "#translations" do
      let(:translations) { create_list(:translation, 10, translation_set: set) }
      let!(:other_translations) { create_list(:translation, 10, translation_set: other_set) }

      it "returns correct translations" do
        expect(subject.translations).to match_array(translations)
      end
    end

    context "when constraints are set for the subject type" do
      let(:constraint) do
        set.constraints.create!(
          organization:,
          subject_type: space.class.name
        )
      end
      let!(:other_constraint) do
        other_set.constraints.create!(
          organization:,
          subject_type: other_space.class.name
        )
      end

      describe "#constraints" do
        it "returns correct constraints" do
          expect(subject.constraints).to contain_exactly(constraint, other_constraint)
        end
      end

      describe "#translations" do
        let(:translations) { create_list(:translation, 10, translation_set: set) }
        let!(:other_translations) { create_list(:translation, 10, translation_set: other_set) }

        it "returns correct translations" do
          expect(subject.translations).to match_array(translations + other_translations)
        end
      end
    end
  end

  context "with component process" do
    let(:space) { create(:participatory_process, organization:) }
    let(:component) { create(:proposal_component, participatory_space: space) }
    let(:other_space) { create(:participatory_process, organization:) }
    let(:other_set) { create(:translation_set) }
    let(:other_component) { create(:proposal_component, participatory_space: other_space) }

    let(:constraint) do
      set.constraints.create!(
        organization:,
        subject: component
      )
    end
    let!(:other_constraint) do
      other_set.constraints.create!(
        organization:,
        subject: other_component
      )
    end

    describe "#constraints" do
      it "returns correct constraints" do
        expect(subject.constraints).to contain_exactly(constraint)
      end
    end

    describe "#translations" do
      let(:translations) { create_list(:translation, 10, translation_set: set) }
      let!(:other_translations) { create_list(:translation, 10, translation_set: other_set) }

      it "returns correct translations" do
        expect(subject.translations).to match_array(translations)
      end
    end
  end
end
