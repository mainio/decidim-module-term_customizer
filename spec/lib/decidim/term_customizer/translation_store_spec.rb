# frozen_string_literal: true

require "spec_helper"

describe Decidim::TermCustomizer::TranslationStore do
  subject { described_class.new(translations) }

  let(:translations) do
    {
      one: {
        two: {
          three1: "One two three1",
          three2: "One two three2"
        }
      },
      first_level: {
        second_level: {
          third_level: "First second third"
        }
      }
    }
  end

  describe "#term" do
    it "returns expected term for existing keys" do
      expect(subject.term("one.two.three1")).to eq("One two three1")
      expect(subject.term("one.two.three2")).to eq("One two three2")
      expect(subject.term("first_level.second_level.third_level")).to eq("First second third")
    end

    it "returns nil for unexisting keys" do
      expect(subject.term("unexisting.key")).to be_nil
    end
  end

  describe "#by_key" do
    it "returns a specific transation for specific key" do
      expect(subject.by_key("one.two.three1").length).to eq(1)
      expect(subject.by_key("one.two.three2").length).to eq(1)
      expect(
        subject.by_key("first_level.second_level.third_level").length
      ).to eq(1)
    end

    it "returns all translations for matching keys" do
      expect(subject.by_key("one.two.three").length).to eq(2)
      expect(subject.by_key("two").length).to eq(2)
      expect(subject.by_key("first").length).to eq(1)
      expect(subject.by_key("second").length).to eq(1)
      expect(subject.by_key("third").length).to eq(1)
    end
  end

  describe "#by_term" do
    context "when case insensitive" do
      it "returns a specific transation for specific term" do
        expect(subject.by_term("One two three1").length).to eq(1)
        expect(subject.by_term("One two three2").length).to eq(1)
        expect(subject.by_term("First second third").length).to eq(1)
      end

      it "returns all translations for matching terms" do
        expect(subject.by_term("one").length).to eq(2)
        expect(subject.by_term("two").length).to eq(2)
        expect(subject.by_term("first").length).to eq(1)
        expect(subject.by_term("second").length).to eq(1)
      end
    end

    context "when case sensitive" do
      it "returns a specific transation for specific term" do
        expect(
          subject.by_term("One two three1", case_sensitive: true).length
        ).to eq(1)
        expect(
          subject.by_term("One two three2", case_sensitive: true).length
        ).to eq(1)
        expect(
          subject.by_term("First second third", case_sensitive: true).length
        ).to eq(1)
      end

      it "does not return specific transations for lowercase terms" do
        expect(
          subject.by_term("one two three1", case_sensitive: true).length
        ).to eq(0)
        expect(
          subject.by_term("one two three2", case_sensitive: true).length
        ).to eq(0)
        expect(
          subject.by_term("first second third", case_sensitive: true).length
        ).to eq(0)
      end
    end
  end
end
