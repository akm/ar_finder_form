require 'rubygems'
gem 'rspec', '>= 1.1.4'
require 'rake'
require 'rake/rdoctask'
require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
 
desc 'Default: run unit tests.'
task :default => :spec
 
task :pre_commit => [:spec, 'coverage:verify']
 
desc 'Run all specs under spec/**/*_spec.rb'
Spec::Rake::SpecTask.new(:spec => 'coverage:clean') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['--options', 'spec/spec.opts']
  t.rcov_dir = 'coverage'
  t.rcov = true
  # t.rcov_opts = ["--include-file", "lib\/*\.rb", "--exclude", "spec\/"]
  t.rcov_opts = ["--exclude", "spec\/"]
end
 
desc 'Generate documentation for the ar_finder_form plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'FinderForm'
  rdoc.options << '--line-numbers' << '--inline-source' << '-c UTF-8'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
 
namespace :coverage do
  desc "Delete aggregate coverage data."
  task(:clean) { rm_f "coverage" }
 
  desc "verify coverage threshold via RCov"
  RCov::VerifyTask.new(:verify => :spec) do |t|
    t.threshold = 100.0 # Make sure you have rcov 0.7 or higher!
    t.index_html = 'coverage/index.html'
  end
end
 
begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "ar_finder_form"
    s.summary  = "ar_finder_form provides a DSL to define form for options to find/paginate"
    s.description  = "ar_finder_form provides a DSL to define form for options to find/paginate"
    s.email    = "akima@gmail.com"
    s.homepage = "http://github.com/akm/ar_finder_form/"
    s.authors  = ["Takeshi Akima"]
    s.add_dependency("activerecord")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
