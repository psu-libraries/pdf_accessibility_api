# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'New job' do
  it 'shows upload link and submit button' do
    visit new_job_path

    # within '#jobs-table' do
    #   expect(page).to have_link('file1.pdf', href: job_path(job_completed))
    #   expect(page).to have_link('file2.pdf', href: job_path(job_processing))
    #   expect(page).to have_content('completed')
    #   expect(page).to have_content('processing')
    #   expect(page).to have_content('Jul 22, 2024 10:30 AM')
    #   expect(page).to have_content('Jul 21, 2024 9:00 AM')
    # end
  end

  context 'when the user has no recent jobs' do
    it 'displays the no recent jobs methods' do
      visit new_job_path
      expect(page).to have_content(I18n.t('ui_page.upload.no_file'))
    end
  end

  context 'when the user has displayed a recent job' do
    it 'displays the recent files that had jobs created for them'
  end

  it 'redirects to the job show page for a new job when one is create' do
    visit new_job_path
    # upload
    click_link 'Submit'
    expect(page).to have_current_path(job_path(job_completed))
  end
end
