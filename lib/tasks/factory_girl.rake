namespace :factory_girl do
  desc 'Verify that all FactoryGirl factories are valid'
  task lint: :environment do
    if Rails.env.test?
      FactoryGirl.factories.each do |factory|
        DatabaseCleaner.start
        FactoryGirl.lint [factory], traits: true
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake factory_girl:lint RAILS_ENV='test'")
    end
  end
end
