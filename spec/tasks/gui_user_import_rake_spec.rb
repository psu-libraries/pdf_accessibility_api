# frozen_string_literal: true

require 'rails_helper'
require 'rake'
require 'tempfile'

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe 'gui_users:import', type: :task do
  let(:task_name) { 'gui_users:import' }
  let(:task) { Rake::Task[task_name] }

  before(:all) do
    Rails.application.load_tasks unless Rake::Task.task_defined?('gui_users:import')
  end

  before do
    task.reenable
  end

  def build_csv(contents)
    file = Tempfile.new(['gui-user-import', '.csv'])
    file.write(contents)
    file.rewind
    file
  end

  context 'when the csv rows have new emails and locations' do
    it 'creates and links records' do
      csv = build_csv(<<~CSV)
        Email,Location
        NEW.USER@example.com,Main Campus
        ANOTHER.USER@example.com,Another Campus
      CSV

      expect { task.invoke(csv.path) }
        .to change(GUIUser, :count).by(2)
        .and change(Unit, :count).by(2)

      gui_user_one = GUIUser.find_by(email: 'new.user@example.com')
      expect(gui_user_one).to be_present
      expect(gui_user_one.unit).to be_present
      expect(gui_user_one.unit.name).to eq('Main Campus')

      gui_user_two = GUIUser.find_by(email: 'another.user@example.com')
      expect(gui_user_two).to be_present
      expect(gui_user_two.unit).to be_present
      expect(gui_user_two.unit.name).to eq('Another Campus')
    ensure
      csv&.close
      csv&.unlink
    end
  end

  context 'when the gui user exists but the location is new' do
    it 'updates the user unit association' do
      old_unit = create(:unit, name: 'Old Campus')
      gui_user = create(:gui_user, email: 'existing@example.com', unit: old_unit)

      csv = build_csv(<<~CSV)
        Email,Location
        existing@example.com,New Campus
      CSV

      expect { task.invoke(csv.path) }
        .to change(Unit, :count).by(1)
        .and not_change(GUIUser, :count)

      expect(gui_user.reload.unit.name).to eq('New Campus')
    ensure
      csv&.close
      csv&.unlink
    end
  end

  context 'when rows are missing required values' do
    it 'skips invalid rows' do
      csv = build_csv(<<~CSV)
        Email,Location
        ,No Email Campus
        no-location@example.com,
      CSV

      expect { task.invoke(csv.path) }
        .to not_change(GUIUser, :count)
        .and not_change(Unit, :count)
    ensure
      csv&.close
      csv&.unlink
    end
  end

  context 'when gui user and unit already exist and are already linked' do
    it 'does not change persisted data' do
      existing_unit = create(:unit, name: 'Already Linked Campus')
      gui_user = create(:gui_user, email: 'already-linked@example.com', unit: existing_unit)

      csv = build_csv(<<~CSV)
        Email,Location
        already-linked@example.com,Already Linked Campus
      CSV

      expect { task.invoke(csv.path) }
        .to not_change(GUIUser, :count)
        .and not_change(Unit, :count)

      expect(gui_user.reload.unit_id).to eq(existing_unit.id)
    ensure
      csv&.close
      csv&.unlink
    end
  end
end
