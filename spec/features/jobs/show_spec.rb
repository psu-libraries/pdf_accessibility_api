# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Jobs show', :js do
  let!(:gui_user) { create(:gui_user, email: 'test1@psu.edu') }
  let(:job_attrs) do
    {
      source_url: 'https://example.com/file1.pdf',
      output_object_key: 'file1.pdf',
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

  it 'shows all job metadata and download link when output_url is present' do
    job = create(:job, job_attrs.merge(output_url: 'http://example.com/result1.pdf'))
    visit job_path(job)

    expect(page).to have_content('Job Details')
    expect(page).to have_content('file1.pdf')
    expect(page).to have_content('abc123')
    expect(page).to have_content('Jul 22, 2024 10:30 AM')
    expect(page).to have_content('Jul 22, 2024 11:00 AM')
    expect(page).to have_content('completed')
    expect(page).to have_link('Click to download', href: 'http://example.com/result1.pdf')
    expect(page).to have_content('Errors:')
    expect(page).to have_content('None')
    expect(page).to have_link('<< Jobs List', href: jobs_path)
  end

  it "shows 'Expired' if output_url is present and output_url_expired? is true" do
    job = Job.create!(job_attrs.merge(output_url: 'http://example.com/result1.pdf', output_url_expires_at: 1.hour.ago))
    visit job_path(job)

    expect(page).to have_content('Download: Expired')
  end

  it "shows 'Not available' if no output_url" do
    job = Job.create!(job_attrs.merge(output_url: nil, output_url_expires_at: 1.hour.from_now))
    visit job_path(job)

    expect(page).to have_content('Download: Not available')

    job2 = Job.create!(job_attrs.merge(output_url: nil, output_url_expires_at: nil))
    visit job_path(job2)

    expect(page).to have_content('Download: Not available')
  end

  it 'shows error message if present' do
    job = Job.create!(job_attrs.merge(processing_error_message: 'Something went wrong'))
    visit job_path(job)

    expect(page).to have_content('Errors:')
    expect(page).to have_content('Something went wrong')
  end
end
