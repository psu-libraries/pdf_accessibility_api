# frozen_string_literal: true

# Default: prevent jobs from running (but queue them)
RSpec.configure do |config|
  # Use the inline adapter for ActiveJob in
  # tests with `active_job_inline: true` tag
  config.around(:each, :active_job_inline) do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    example.run
  ensure
    ActiveJob::Base.queue_adapter = original_adapter
  end
end
