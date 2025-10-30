# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'New Image job', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }

  before do
    login_as(gui_user)
  end

  it 'shows content and browse button' do
    visit new_image_job_path
    expect(page).to have_content(I18n.t('heading'))
    expect(page).to have_content(I18n.t('image.upload.heading'))
    expect(page).to have_content(I18n.t('image.upload.subheading'))
    expect(page).to have_button('browse files')
  end

  it 'redirects to the job show page for a new job when one is created' do
    with_minio_env do
      visit new_image_job_path
      while page.has_no_selector?('.uppy-Dashboard-AddFiles')
        sleep 0.1
      end

      page
        .first('.uppy-Dashboard-input', visible: false)
        .attach_file(Rails.root.join('spec', 'fixtures', 'files', 'lion.jpg'))
      while page.has_no_selector?('.uppy-StatusBar-actionBtn--upload')
        sleep 0.1
      end
      click_button 'Upload 1 file'
      sleep 2
      expect(page).to have_current_path(image_job_path(Job.last))
    end
  end

  it 'shows alert and does not proceed if the filename contains a special character' do
    with_minio_env do
      visit new_image_job_path
      while page.has_no_selector?('.uppy-Dashboard-AddFiles')
        sleep 0.1
      end

      page
        .first('.uppy-Dashboard-input', visible: false)
        .attach_file(Rails.root.join('spec', 'fixtures', 'files', 'lion_with_$$$.jpg'))
      while page.has_no_selector?('.uppy-StatusBar-actionBtn--upload')
        sleep 0.1
      end
      click_button 'Upload 1 file'
      sleep 0.1
      expect(page.driver.browser.switch_to.alert.text).to include('File names can only contain letters')
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_current_path(new_image_job_path)
    end
  end
end
