# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'New PDF job', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu', unit: unit) }
  let!(:unit) { create(:unit, user_daily_page_limit: 10, overall_page_limit: 50) }
  let!(:pdf_job) { create(:pdf_job, owner: gui_user, page_count: 3) }

  before do
    login_gui_user(gui_user)
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

  it 'shows daily limit and current page usage' do
    visit new_pdf_job_path
    expect(page).to have_content(I18n.t('pdf.upload.remaining_pages', pages_used: 3, pages_left: 7))
  end

  context 'when upload is successful' do
    it 'creates a new PdfJob, saves page_count, and redirects to the job show page' do
      with_minio_env do
        pdf_job_count_before = PdfJob.count

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
        expect(PdfJob.count).to eq(pdf_job_count_before + 1)
        expect(PdfJob.last.page_count).to eq(1)
        expect(page).to have_current_path(pdf_job_path(PdfJob.last))
      end
    end
  end

  context 'when the filename contains a special character' do
    it 'shows alert and does not proceed' do
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

  context 'when the user has exceeded their daily page limit' do
    before do
      create(:pdf_job, owner: gui_user, page_count: 15)
    end

    it 'displays that they have reached their limit' do
      visit new_pdf_job_path
      expect(page).to have_content(I18n.t('pdf.upload.remaining_pages',
        pages_used: gui_user.total_pages_processed_last_24_hours,
        pages_left: 0))
    end

    it 'shows an error message and does not proceed with the upload' do
      with_minio_env do
        pdf_job_count_before = PdfJob.count
        visit new_pdf_job_path
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
        sleep 0.1
        expect(page).to have_content('Failed to upload testing.pdf')
        expect(page).to have_content("Page count exceeds the user's daily page limit of 10")
        expect(PdfJob.count).to eq(pdf_job_count_before)
        expect(page).to have_current_path(new_pdf_job_path)
      end
    end
  end
end
