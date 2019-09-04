require 'aws-sdk'

Aws.config.update({
    region: 'us-east-2',
    access_key_id: ENV['ACCESS_KEY'],
    secret_access_key: ENV['SECRET_KEY'],
                  })


S3_BUCKET = Aws::S3::Resource.new.bucket('auto-grader-bucket')
EC2_INSTANCE = Aws::EC2::Instance.new('i-08e1f3ee6c0bf2f97')