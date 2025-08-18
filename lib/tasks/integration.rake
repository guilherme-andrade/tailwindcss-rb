namespace :spec do
  desc "Run integration tests with dummy Rails app"
  task :integration do
    Dir.chdir("spec/dummy_rails_app") do
      sh "bundle install --quiet"
      sh "bundle exec rspec spec/integration"
    end
  end
end

desc "Run all tests including integration"
task :all_tests => ["spec", "spec:integration"]