 # frozen_string_literal: true

 class JobChannel < ApplicationCable::Channel
   def subscribed
     job = Job.find(params[:id])
     stream_for job
   end
 end
