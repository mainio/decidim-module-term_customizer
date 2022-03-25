# frozen_string_literal: true

shared_context "with translation import data" do
  let(:expected_data) do
    [
      {
        locale: "fi",
        key: "activerecord.models.decidim/participatory_process_group.one",
        value: "Osallisuusprosessiryhmä"
      },
      {
        locale: "en",
        key: "activerecord.models.decidim/participatory_process_group.one",
        value: "Participatory process group"
      },
      {
        locale: "fi",
        key: "activerecord.models.decidim/participatory_process.other",
        value: "Osallisuusprosessit"
      },
      {
        locale: "en",
        key: "activerecord.models.decidim/participatory_process.other",
        value: "Participatory processes"
      },
      {
        locale: "fi",
        key: "activerecord.models.decidim/participatory_process.one",
        value: "Osallisuusprosessi"
      },
      {
        locale: "en",
        key: "activerecord.models.decidim/participatory_process.one",
        value: "Participatory process"
      }
    ]
  end
end

shared_examples "translation importer" do
  include_context "with translation import data"

  describe "#collection" do
    it "parses the correct collection" do
      expect(subject.collection.length).to be(6)

      # Check that collection data matches with expected data
      expected_data.each_with_index do |data, index|
        data.each do |key, value|
          expect(subject.collection[index].send(key)).to eq(value)
        end
      end
    end
  end

  describe "#import" do
    context "with block" do
      let(:translation_set) { create(:translation_set) }

      it "creates the records" do
        expect do
          subject.import do |collection|
            collection.each do |record|
              record.translation_set = translation_set
              record.save!
            end
          end
        end.to change { Decidim::TermCustomizer::Translation.count }.by(6)

        # Check that saved data matches with expected data
        expected_data.each do |data|
          tr = translation_set.translations.find_by(
            locale: data[:locale],
            key: data[:key]
          )
          expect(tr).to be_a(Decidim::TermCustomizer::Translation)
          expect(tr.value).to eq(data[:value])
        end
      end
    end

    context "with no block" do
      it "raises an ActiveRecord::RecordInvalid" do
        expect do
          subject.import
        end.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end

shared_examples "translation import reader" do
  subject { described_class.new(file) }

  include_context "with translation import data"

  it "yields all the data correctly" do
    data = []
    subject.read_rows do |row, index|
      data[index] = row.map(&:to_s)
    end

    expected_array = []
    expected_array << ["id"] + expected_data.first.keys.map(&:to_s)
    expected_data.each_with_index do |row, index|
      expected_array << [(index + 1).to_s] + row.values.map(&:to_s)
    end

    expect(data).to eq(expected_array)
  end
end
