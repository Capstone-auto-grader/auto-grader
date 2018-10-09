json.extract! submission, :id, :grade, :submission_zip, :created_at, :updated_at
json.url submission_url(submission, format: :json)
