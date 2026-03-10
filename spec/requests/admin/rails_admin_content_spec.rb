# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'RailsAdmin content' do
  let!(:admin_user) { create(:gui_user, email: 'test1@psu.edu') }

  let!(:unit) do
    create(:unit,
           name: 'Accessibility Services Unit',
           user_daily_page_limit: 123,
           overall_page_limit: 45_678)
  end

  let!(:api_user_record) do
    create(:api_user,
           name: 'API User',
           email: 'api.user@example.com',
           unit: unit,
           webhook_endpoint: 'https://example.com/webhook')
  end
  let!(:gui_user_record) { create(:gui_user, email: 'gui.user@example.com', unit: unit) }

  let(:api_recent_job) { create(:pdf_job, owner: api_user_record, page_count: 401, created_at: 2.hours.ago) }
  let(:api_old_job) { create(:pdf_job, owner: api_user_record, page_count: 7, created_at: 2.days.ago) }
  let(:gui_recent_job) { create(:pdf_job, owner: gui_user_record, page_count: 503, created_at: 3.hours.ago) }
  let(:gui_old_job) { create(:pdf_job, owner: gui_user_record, page_count: 11, created_at: 2.days.ago) }

  let!(:job_record) do
    create(:pdf_job,
           owner: api_user_record,
           status: 'completed',
           page_count: 321,
           object_key: 'remediation_file.pdf',
           source_url: 'https://example.com/input.pdf')
  end

  before do
    login_as(admin_user)
  end

  it 'shows Unit list and show content' do
    get '/admin/unit'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Accessibility Services Unit')

    get "/admin/unit/#{unit.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Accessibility Services Unit')
    expect(response.body).to include('123')
    expect(response.body).to include('45678')
    expect(response.body).to include(unit.total_pages_processed.to_s)
  end

  it 'shows GuiUser list and show content' do
    get '/admin/gui_user'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('gui.user@example.com')

    get "/admin/gui_user/#{gui_user_record.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('gui.user@example.com')
    expect(response.body).to include('Accessibility Services Unit')
    expect(response.body).to include(gui_user_record.total_pages_processed_last_24_hours.to_s)
  end

  it 'shows ApiUser list and show content including' do
    get '/admin/api_user'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('API User')
    expect(response.body).to include('api.user@example.com')

    get "/admin/api_user/#{api_user_record.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('API User')
    expect(response.body).to include('api.user@example.com')
    expect(response.body).to include('https://example.com/webhook')
    expect(response.body).to include('Accessibility Services Unit')
    expect(response.body).to include(api_user_record.total_pages_processed_last_24_hours.to_s)
  end

  it 'shows Job list and show content' do
    get '/admin/job'
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(job_record.uuid)

    get "/admin/job/#{job_record.id}"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(job_record.uuid)
    expect(response.body).to include('PdfJob')
    expect(response.body).to include('completed')
    expect(response.body).to include('321')
    expect(response.body).to include('remediation_file.pdf')
  end
end
