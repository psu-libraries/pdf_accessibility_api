# frozen_string_literal: true

namespace :tmp do
  desc 'Delete all files in tmp/uploads'
  task uploads_cleanup: :environment do
    uploads_dir = Rails.root.join('tmp', 'uploads')
    if Dir.exist?(uploads_dir)
      files = Dir.glob("#{uploads_dir}/*")
      if files.any?
        files.each do |file|
          File.delete(file)
        end
        puts "Deleted #{files.count} files from tmp/uploads."
      else
        puts 'No files found in tmp/uploads.'
      end
    else
      puts 'Directory tmp/uploads does not exist.'
    end
  end
end
