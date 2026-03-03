# frozen_string_literal: true

namespace :s3 do
  desc 'Check S3 for remediation output files once'
  task check_final_files_once: :environment do
    CheckS3ForFinalFilesService.new.call(run_once: true)
  end

  desc 'Continuously poll S3 for remediation output files (dedicated worker)'
  task check_final_files_loop: :environment do
    CheckS3ForFinalFilesService.new.call
  end
end
