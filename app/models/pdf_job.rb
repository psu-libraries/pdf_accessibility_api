# frozen_string_literal: true

class PdfJob < Job
  belongs_to :owner, polymorphic: true
  validates :source_url, format: { with: URI::RFC2396_PARSER.make_regexp }, if: -> { owner_type == 'APIUser' }

  validates :page_count_within_quota, if: :page_count_set_from_nil?

  delegate :webhook_endpoint, :webhook_key, to: :owner, prefix: false

  def output_url_expired?
    output_url_expires_at.present? && output_url_expires_at < Time.zone.now
  end

  private

    def broadcast_to_job_channel
      JobChannel.broadcast_to(self, {
                                output_object_key: output_object_key,
                                status: status,
                                output_url: output_url,
                                output_url_expired: output_url_expired?,
                                finished_at: finished_at,
                                processing_error_message: processing_error_message
                              })
    end

    def page_count_within_quota
      total_quota = owner.unit.overall_page_limit
      daily_quota = owner.unit.daily_page_limit

      if page_count + owner.unit.total_pages_processed > total_quota
        errors.add(:page_count, "exceeds the unit's overall page limit of #{total_quota}")
      end

      if page_count + owner.total_pages_processed_today > daily_quota
        errors.add(:page_count, "exceeds the owner's daily page limit of #{daily_quota}")
      end
    end

    def page_count_set_from_nil?
      will_save_change_to_page_count? &&
        page_count_in_database.nil? &&
        page_count.present?
    end
end
