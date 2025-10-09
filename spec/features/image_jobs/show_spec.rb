# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Image Jobs show', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let(:job_attrs) do
    {
      output_object_key: 'file1.jpg',
      uuid: 'abc123',
      created_at: Time.new(2024, 7, 22, 10, 30),
      finished_at: Time.new(2024, 7, 22, 11, 0, 0, '-04:00'),
      status: 'completed',
      owner: gui_user
    }
  end

  before do
    login_as(gui_user)
  end

  it 'shows all job metadata' do
    pending 'TODO: implement in 161'
  end
end
