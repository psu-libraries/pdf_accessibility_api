# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Image Jobs index', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let!(:job_completed) { create(:image_job, output_object_key: 'test.jpg',
                                          status: 'completed',
                                          created_at: Time.new(2024, 7, 22, 10, 30),
                                          owner: gui_user) }
  let!(:job_processing) { create(:image_job, output_object_key: 'test2.jpg',
                                           status: 'processing',
                                           created_at: Time.new(2024, 7, 21, 9, 0),
                                           owner: gui_user) }

  before do
    login_as(gui_user)
  end

  it 'shows image jobs and their metadata in the table' do
    visit image_jobs_path

    within '#jobs-table' do
      expect(page).to have_link('test.jpg', href: image_job_path(job_completed))
      expect(page).to have_link('test2.jpg', href: image_job_path(job_processing))
      expect(page).to have_content('completed')
      expect(page).to have_content('processing')
      expect(page).to have_content('Jul 22, 2024 10:30 AM')
      expect(page).to have_content('Jul 21, 2024 9:00 AM')
    end
  end

  it 'redirects to the image job show page when a link is clicked' do
    visit image_jobs_path

    click_link 'test.jpg'
    expect(page).to have_current_path(image_job_path(job_completed))
  end

  it 'contains a link to create a new image job' do
    visit image_jobs_path
    click_link 'Generate alt-text for a new image'
    expect(page).to have_current_path(new_image_job_path)
  end

  xit 'updates status in real-time' do
    visit image_jobs_path
    # TODO: Implement in 161
  end
end
