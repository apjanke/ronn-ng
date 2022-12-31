Gem::Specification.new do |s|
  s.name = 'ronn-ng'
  s.version = '0.10.1.pre1'
  s.date = '2020-12-22'
  s.required_ruby_version = '>= 2.4'

  s.summary     = 'Builds man pages from Markdown'
  s.description = 'Ronn-NG builds manuals in HTML and Unix man page format from Markdown.'
  s.homepage    = 'https://github.com/apjanke/ronn-ng'
  s.license     = 'MIT'

  s.authors     = ['Andrew Janke']
  s.email       = 'floss@apjanke.net'

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/apjanke/ronn-ng/issues',
    'source_code_uri'   => 'https://github.com/apjanke/ronn-ng',
    'changelog_uri'     => 'https://github.com/apjanke/ronn-ng/blob/main/CHANGES'
  }

  # = MANIFEST =
  s.files = %w[
    AUTHORS
    CHANGES
    Gemfile
    Gemfile.lock
    INSTALLING.md
    LICENSE.txt
    README.md
    Rakefile
    bin/ronn
    completion/bash/ronn
    completion/zsh/_ronn
    config.ru
    lib/ronn.rb
    lib/ronn/document.rb
    lib/ronn/index.rb
    lib/ronn/roff.rb
    lib/ronn/server.rb
    lib/ronn/template.rb
    lib/ronn/template/80c.css
    lib/ronn/template/dark.css
    lib/ronn/template/darktoc.css
    lib/ronn/template/default.html
    lib/ronn/template/man.css
    lib/ronn/template/print.css
    lib/ronn/template/screen.css
    lib/ronn/template/toc.css
    lib/ronn/utils.rb
    man/index.html
    man/index.txt
    man/ronn-format.7
    man/ronn-format.7.ronn
    man/ronn.1
    man/ronn.1.ronn
    ronn-ng.gemspec
  ]
  # = MANIFEST =

  s.executables = ['ronn']
  s.test_files = s.files.select { |path| path =~ /^test\/.*_test.rb/ }

  s.extra_rdoc_files = %w[LICENSE.txt AUTHORS]
  s.add_dependency 'kramdown',              '~> 2.1'
  s.add_dependency 'kramdown-parser-gfm',   '~> 1.0.1'
  s.add_dependency 'mustache',              '~> 1.0'
  s.add_dependency 'nokogiri',              '~> 1.10', '>= 1.10.10'
  s.add_development_dependency 'rack',      '~> 2.2',  '>= 2.2.3'
  s.add_development_dependency 'rake',      '~> 12.3', '>= 12.3.3'
  s.add_development_dependency 'rubocop',   '~> 0.88', '>= 0.88.0'
  s.add_development_dependency 'sinatra',   '~> 2.0',  '>= 2.0.8'
  s.add_development_dependency 'test-unit', '~> 3.3',  '>= 3.3.6'

  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Ronn']
  s.require_paths = %w[lib]
end
