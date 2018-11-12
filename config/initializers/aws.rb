require 'aws-sdk'

Aws.config.update({
    access_key_id: ENV['ACCESS_KEY'],
    secret_access_key: ENV['SECRET_KEY'],
                  })


S3_BUCKET = Aws::S3::Resource.new.bucket('auto-grader-capstone')