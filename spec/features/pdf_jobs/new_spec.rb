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
    expect(page).to have_content(I18n.t('pdf.privacy_notice.header'))
    expect(page).to have_content(I18n.t('pdf.privacy_notice.adobe'))
    expect(page).to have_content(I18n.t('pdf.privacy_notice.aws'))
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
        .attach_file(Rails.root.join('spec', 'fixtures', 'files', 'testing.pdf'))
      while page.has_no_selector?('.uppy-StatusBar-actionBtn--upload')
        sleep 0.1
      end
      click_button 'Upload 1 file'
      sleep 2
      expect(page).to have_current_path(pdf_job_path(Job.last))
    end
  end

  it 'shows alert and does not proceed if the filename contains a special character' do
    with_minio_env do
      visit new_pdf_job_path
      while page.has_no_selector?('.uppy-Dashboard-AddFiles')
        sleep 0.1
      end

      page
        .first('.uppy-Dashboard-input', visible: false)
        .attach_file(Rails.root.join('spec', 'fixtures', 'files', 'special_character_ñ.pdf'))
      while page.has_no_selector?('.uppy-StatusBar-actionBtn--upload')
        sleep 0.1
      end
      click_button 'Upload 1 file'
      sleep 0.1
      expect(page.driver.browser.switch_to.alert.text).to include('File names can only contain letters')
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_current_path(new_pdf_job_path)
    end
  end
end
