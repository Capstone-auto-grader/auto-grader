namespace 'db:fixtures' do
  desc "generate fixtures from the current database"

  task :export => :environment do
    Rails.application.eager_load!
    models = defined?(ApplicationRecord) ? ApplicationRecord.descendants : ActiveRecord::Base.descendants
    models.each do |model|
      puts "exporting: #{model}"

      # Hoge::Fuga -> test/fixtures/hoge/fuga.yml
      filepath = Rails.root.join('test/fixtures', "#{model.name.underscore}.yml")
      FileUtils.mkdir_p filepath.dirname

      filepath.open('w') do |file|
        hash = {}
        model.find_each do |r|
          key = r.try(:name) || "#{filepath.basename('.*')}_#{r.id}"
          hash[key] = r.attributes.except(:password_digest)
        end
        file.write hash.to_yaml
      end
    end
  end
end