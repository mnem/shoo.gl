desc "Deploy to gh-pages"
task :deploy_gh do
  sh "rm -rf build"
  sh "bundle exec middleman build --clean --verbose"
  sh "bundle exec middleman deploy"
end

task :default => [:deploy_gh]
