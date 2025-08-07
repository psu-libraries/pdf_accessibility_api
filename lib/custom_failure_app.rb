# frozen_string_literal: true

class CustomFailureApp
  def self.call(env)
    original_path = env['ORIGINAL_FULLPATH'] || env['REQUEST_PATH'] || '/'
    if original_path.start_with?('/api')
      [401, { 'Content-Type' => 'application/json' },
       [{ message: 'Not authorized', code: 401 }.to_json]]
    else
      [302, { 'Location' => '/unauthorized', 'Content-Type' => 'text/html' },
       ['Redirecting to unauthorized page']]
    end
  end
end
