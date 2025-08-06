# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'New job', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(gui_user)
  end

  it 'shows content and submit button' do
    visit new_job_path
    expect(page).to have_content(I18n.t('heading'))
    expect(page).to have_content(I18n.t('upload.heading'))
    expect(page).to have_button('Upload')
  end

  it 'requires a file to be uploaded to submit' do
    visit new_job_path
    click_button 'Upload'
    expect(page).to have_content(I18n.t('upload.error'))
  end

  it 'redirects to the job show page for a new job when one is created' do
    file_count = Rails.root.glob('tmp/uploads/*_testing.pdf').count
    visit new_job_path
    attach_file('./spec/fixtures/files/testing.pdf')
    click_button 'Upload'
    sleep 1
    expect(Rails.root.glob('tmp/uploads/*_testing.pdf').count).to eq(file_count + 1)
    expect(page).to have_current_path(job_path(Job.last))
  end
end
