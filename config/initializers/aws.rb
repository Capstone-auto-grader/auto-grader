AWS.config(
    access_key_id: ENV['ACCESS_KEY']
    secret_key_id: ENV['SECRET_KEY']
)

S3_BUCKET = AWS::S3.new.buckets[ENV['S3_BUCKET']]