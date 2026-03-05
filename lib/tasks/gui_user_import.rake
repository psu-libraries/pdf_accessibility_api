# frozen_string_literal: true

require 'csv'

namespace :gui_users do
  desc 'Import GUI users and Units from CSV using `Email` and `Location` columns. ' \
       'Usage: rake "gui_users:import[path/to/users.csv]"'
  task :import, [:file_path] => :environment do |_task, args|
    file_path = args[:file_path]

    csv = CSV.read(file_path, headers: true, header_converters: ->(header) { header.to_s.strip.downcase })

    csv.each do |row|
      email = row['email']&.strip&.downcase
      location_name = row['location']&.strip

      next if email.blank? || location_name.blank?

      gui_user = GUIUser.find_or_create_by!(email: email)
      unit = Unit.find_or_create_by!(name: location_name) do |new_unit|
        new_unit.user_daily_page_limit = 50
      end

      gui_user.update!(unit: unit)
    end
  end
end
