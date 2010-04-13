require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "tweetdump"
    gem.summary = %Q{Simple CLI program to dump X number of tweets as raw JSON from Twitter's Search or Streaming APIs}
    gem.description = %Q{
      Initially I created this because I wanted to compare the Streaming and Search APIs.
      It turns out that completely by accident it can also do the neat trick of connecting indefinitely to either API,
      and feeding fresh tweets to whatever program you pipe the output to.

      % tweetdump -h # Usage instructions
    }
    gem.email = "logan@logankoester.com"
    gem.homepage = "http://github.com/logankoester/tweetdump"
    gem.authors = ["Logan Koester"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    gem.add_dependency "optiflag", ">= 0.7"
    gem.add_dependency "tweetstream"
    gem.add_dependency "eventmachine"
    gem.add_dependency "hashie"
    gem.add_dependency "twitter"
    gem.executables = ['bin/tweetdump']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tweetdump #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
