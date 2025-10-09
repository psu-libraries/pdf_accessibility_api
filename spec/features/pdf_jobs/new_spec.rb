# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'New PDF job', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(gui_user)
  end

  it 'shows content and submit button' do
    visit new_pdf_job_path
    expect(page).to have_content(I18n.t('heading'))
    expect(page).to have_content(I18n.t('pdf.upload.heading'))
    expect(page).to have_content('Drop files here')
    expect(page).to have_button('browse files')
  end

  it 'redirects to the job show page for a new job when one is created' do
    with_minio_env do
      visit new_pdf_job_path
      # Wait for Uppy to load
      while page.has_no_selector?('.uppy-Dashboard-AddFiles')
        sleep 0.1
      end

      page
        .first('.uppy-Dashboard-input', visible: false)
        .attach_file(Rails.root.join('spec', 'fixtures', 'files', 'lion.png'))
      while page.has_no_selector?('.uppy-StatusBar-actionBtn--upload')
        sleep 0.1
      end
      click_button 'Upload 1 file'
      sleep 2
      expect(page).to have_current_path(pdf_job_path(Job.last))
    end
  end
end
