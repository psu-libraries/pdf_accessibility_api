 # frozen_string_literal: true

 class JobChannel < ApplicationCable::Channel
   def subscribed
     job = Job.find(params[:id])
     print('TESTING JOB CHANNEL SUBSCRIPTION') # remove
     print("JOB: #{job.inspect}") # remove
     stream_for job
   end
 end
