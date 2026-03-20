# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Site Navigation' do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }

  context 'when gui user is admin' do
    before do
      login_gui_user(gui_user, admin: true)
    end

    it 'shows a link to the admin page' do
      visit new_pdf_job_path
      expect(page).to have_link('New PDF Job', href: '/pdf_jobs/new')
      expect(page).to have_link('My PDF Jobs', href: '/pdf_jobs')
      expect(page).to have_link('New Alt-Text Job', href: '/image_jobs/new')
      expect(page).to have_link('My Alt-Text Jobs', href: '/image_jobs')
      expect(page).to have_link('Admin', href: '/admin')
    end
  end

  context 'when gui user is not admin' do
    before do
      login_gui_user(gui_user, admin: false)
    end

    it 'does not show a link to the admin page' do
      visit new_pdf_job_path
      expect(page).to have_link('New PDF Job', href: '/pdf_jobs/new')
      expect(page).to have_link('My PDF Jobs', href: '/pdf_jobs')
      expect(page).to have_link('New Alt-Text Job', href: '/image_jobs/new')
      expect(page).to have_link('My Alt-Text Jobs', href: '/image_jobs')
      expect(page).to have_no_link('Admin', href: '/admin')
    end
  end
end
