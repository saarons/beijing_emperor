require 'rake'
begin
  require 'jeweler'
  require 'spec/rake/spectask'
rescue LoadError
  puts "Please install RSpec & Jeweler"
end

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "beijing_emperor"
  gemspec.summary = "An ActiveModel interface to Tokyo Tyrant"
  gemspec.email = "samaarons@gmail.com"
  gemspec.homepage = "http://github.com/saarons/beijing_emperor"
  gemspec.authors = ["Sam Aarons"]
  
  gemspec.required_ruby_version = ">= 1.9.1"
  
  gemspec.add_dependency "ruby-tokyotyrant", ">= 0.3.1"
  gemspec.add_dependency "activemodel",      ">= 3.0.pre"
  gemspec.add_dependency "activesupport",    ">= 3.0.pre"
  
  gemspec.add_development_dependency "rspec", ">= 1.2.9"
end

desc "Run all tests"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_opts = ["--color"]
  t.pattern = "test/**/*_spec.rb"
end
