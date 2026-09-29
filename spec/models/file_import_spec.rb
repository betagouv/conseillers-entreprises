require 'rails_helper'

RSpec.describe FileImport do
  describe "#imported_klass" do
    subject(:klass) { described_class.new(entity: entity).importer_klass }

    context "User" do
      let(:entity) { "User" }

      it { is_expected.to eq CsvImport::UserImporter }
    end

    context "Antenne" do
      let(:entity) { "Antenne" }

      it { is_expected.to eq CsvImport::AntenneImporter }
    end
  end

  describe "#result_objects" do
    before do
      create(:antenne, name: "The Antenne", institution: create(:institution, name: "The Institution"))
      file_import.import(commit: true)
    end

    let(:file_import) { create(:file_import, entity: User, file: file_fixture('csv_import/users.csv')) }

    subject(:result_objects) { file_import.result_objects }

    it { is_expected.to contain_exactly(an_instance_of(User).and(have_attributes(email: "marie.dupont@antenne.com"))) }
  end

  describe "DestroyJob is enqueued" do
    before do
      create(:antenne, name: "The Antenne", institution: create(:institution, name: "The Institution"))
      freeze_time
    end

    let(:file_import) { create(:file_import, entity: User, file: file_fixture('csv_import/users.csv')) }

    it do
      expect{ file_import.import(commit: true) }.to have_enqueued_job(FileImport::DestroyJob).with(file_import).at(1.week.from_now)
    end
  end

  describe "#auto_destroy" do
    before do
      create(:antenne, name: "The Antenne", institution: create(:institution, name: "The Institution"))
    end

    let(:file_import) { create(:file_import, entity: User, file: file_fixture('csv_import/users.csv')) }

    it do
      FileImport::DestroyJob.perform_now(file_import)

      expect(file_import).to be_destroyed
    end
  end
end
