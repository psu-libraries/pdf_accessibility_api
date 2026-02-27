# frozen_string_literal: true

class PageCountQuotaValidator
  class Error < StandardError; end

  class QuotaExceededError < Error; end
  class MissingUnitError < Error; end
  class InvalidPageCountError < Error; end

  def self.validate!(owner:, page_count:)
    unit = owner&.unit
    raise MissingUnitError, 'Owner must belong to a unit to validate page quota' if unit.nil?

    page_count_int = Integer(page_count)
    raise InvalidPageCountError, 'page_count must be greater than 0' if page_count_int <= 0

    total_quota = unit.overall_page_limit
    total_processed = unit.total_pages_processed

    if page_count_int + total_processed > total_quota
      raise QuotaExceededError, "page_count exceeds the unit's overall page limit of #{total_quota}"
    end

    todays_quota = unit.user_daily_page_limit
    todays_processed = owner.total_pages_processed_last_24_hours

    if page_count_int + todays_processed > todays_quota
      raise QuotaExceededError, "page_count exceeds the user's daily page limit of #{todays_quota}"
    end

    true
  rescue ArgumentError, TypeError
    raise InvalidPageCountError, 'page_count must be an integer'
  end
end
