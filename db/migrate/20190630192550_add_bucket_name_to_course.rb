class AddBucketNameToCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :s3_bucket, :string
  end
end
