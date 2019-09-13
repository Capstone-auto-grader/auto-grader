require 'aws-sdk'

Aws.config.update({
    region: 'us-east-1',
    access_key_id: ENV['ACCESS_KEY'],
    secret_access_key: ENV['SECRET_KEY'],
                  })


S3_BUCKET = Aws::S3::Resource.new.bucket('auto-grader-bucket')
EC2_INSTANCE = Aws::EC2::Instance.new('i-0cf13c8b86e3acce8')