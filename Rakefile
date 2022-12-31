require 'rake/clean'
require 'date'

task default: :test

ROOTDIR = File.expand_path(__dir__).sub(/#{Dir.pwd}(?=\/)/, '.')
LIBDIR = "#{ROOTDIR}/lib".freeze
BINDIR = "#{ROOTDIR}/bin".freeze

task :environment do
  $LOAD_PATH.unshift ROOTDIR unless $LOAD_PATH.include?(ROOTDIR)
  $LOAD_PATH.unshift LIBDIR unless $LOAD_PATH.include?(LIBDIR)
  require_library 'nokogiri'
  require_library 'kramdown'
  ENV['RUBYLIB'] = $LOAD_PATH.join(':')
  ENV['PATH'] = "#{BINDIR}:#{ENV['PATH']}"
end

desc 'Run tests'
task test: :environment do
  $LOAD_PATH.unshift "#{ROOTDIR}/test"
  Dir['test/test_*.rb'].sort.each { |f| require(f) }
end

desc 'Start the server'
task server: :environment do
  if system('type shotgun >/dev/null 2>&1')
    exec 'shotgun config.ru'
  else
    require 'ronn/server'
    Ronn::Server.run('man/*.ronn')
  end
end

desc 'Build the manual'
task man: :environment do
  require 'ronn'
  ENV['RONN_MANUAL'] = 'Ronn Manual'
  ENV['RONN_ORGANIZATION'] = "Ronn-NG #{Ronn.revision}"
  sh 'ronn -w -s toc -r5 --markdown man/*.ronn'
end

desc 'Publish to GitHub pages'
task pages: :man do
  puts '----------------------------------------------'
  puts 'Rebuilding pages ...'
  verbose(false) do
    rm_rf 'pages'
    push_url = `git remote show origin`.grep(/Push.*URL/).first[/git@.*/]
    sh "
      set -e
      git fetch -q origin
      rev=$(git rev-parse origin/gh-pages)
      git clone -q -b gh-pages . pages
      cd pages
      git reset --hard $rev
      rm -f ronn*.html index.html
      cp -rp ../man/ronn*.html ../man/index.txt ../man/index.html ./
      git add -u ronn*.html index.html index.txt
      git commit -m 'rebuild manual'
      git push #{push_url} gh-pages
    ", verbose: false
  end
end

# PACKAGING ============================================================

# Rev Ronn::VERSION
task :rev do
  rev = ENV['REV'] || `git describe --tags`.chomp
  data = File.read('lib/ronn.rb')
  data.gsub!(/^( *)REV *=.*/, "\\1REV = '#{rev.sub(/\Av/, '')}'.freeze")
  File.open('lib/ronn.rb', 'wb') { |fd| fd.write(data) }
  puts "revision: #{rev}"
  puts "version:  #{`ruby -Ilib -rronn -e 'puts Ronn::VERSION'`}"
end

require 'rubygems'
@spec = eval(File.read('ronn-ng.gemspec'))

def package(ext = '')
  "pkg/ronn-ng-#{@spec.version}" + ext
end

desc 'Build packages'
task package: %w[.gem .tar.gz].map { |ext| package(ext) }

desc 'Build and install as local gem'
task install: package('.gem') do
  sh "gem install #{package('.gem')}"
end

directory 'pkg/'
CLOBBER.include('pkg')

file package('.gem') => %w[pkg/ ronn-ng.gemspec] + @spec.files do |f|
  sh 'gem build ronn-ng.gemspec'
  mv File.basename(f.name), f.name
end

file package('.tar.gz') => %w[pkg/] + @spec.files do |f|
  sh <<-SH
    git archive --prefix=ronn-#{source_version}/ --format=tar HEAD |
    gzip > #{f.name}
  SH
end

def source_version
  @source_version ||= `ruby -Ilib -rronn -e 'puts Ronn::VERSION'`.chomp
end

file 'ronn-ng.gemspec' => FileList['{lib,test,bin}/**', 'Rakefile'] do |f|
  # read spec file and split out manifest section
  spec = File.read(f.name)
  head, _manifest, tail = spec.split("  # = MANIFEST =\n")
  # replace version and date
  head.sub!(/\.version = '.*'/, ".version = '#{source_version}'")
  head.sub!(/\.date = '.*'/, ".date = '#{Date.today}'")
  # determine file list from git ls-files
  files = `git ls-files`
          .split("\n")
          .sort
          .reject { |file| file =~ /^\./ }
          .reject { |file| file =~ /^doc/ }
          .map { |file| "    #{file}" }
          .join("\n")
  # piece file back together and write...
  manifest = "  s.files = %w[\n#{files}\n  ]\n"
  spec = [head, manifest, tail].join("  # = MANIFEST =\n")
  File.open(f.name, 'w') { |io| io.write(spec) }
  puts "updated #{f.name}"
end

# Misc ===============================================================

def require_library(name)
  require name
rescue LoadError => e
  unless defined?(Gem)
    warn "warn: #{e}. trying again with rubygems."
    require 'rubygems'
    retry
  end
  abort "fatal: the '#{name}' library is required (gem install #{name})"
end

# make .wrong test files right
task :right do
  Dir['test/*.wrong'].each do |file|
    dest = file.sub(/\.wrong$/, '')
    mv file, dest
  end
end
