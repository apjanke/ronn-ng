Gem::Specification.new do |s|
  s.name = 'ronn-ng'
  s.version = '0.10.1.pre4'
  # As of 2023-09, ronn-ng targets and is tested on Ruby 2.7 for deployment. It'll mostly
  # work on lower versions, but in effect requires >= 2.7 because it needs nokogiri
  # >= 1.14.3 for correct tag name handling, and that nokogiri requires Ruby 2.7.
  s.required_ruby_version = '>= 2.4'

  s.summary     = 'Builds man pages from Markdown'
  s.description = 'Ronn-NG builds manuals in Unix man page and HTML format from Markdown. Ronn-NG is a modern, maintained fork of the original Ronn.'
  s.homepage    = 'https://github.com/apjanke/ronn-ng'
  s.license     = 'MIT'

  s.authors     = ['Andrew Janke']
  s.email       = 'floss@apjanke.net'

  s.metadata = {
    'bug_tracker_uri'       => 'https://github.com/apjanke/ronn-ng/issues',
    'source_code_uri'       => 'https://github.com/apjanke/ronn-ng',
    'changelog_uri'         => 'https://github.com/apjanke/ronn-ng/blob/main/CHANGELOG.md',
    'rubygems_mfa_required' => 'true'
  }

  # = MANIFEST =
  s.files = %w[
    AUTHORS
    CHANGELOG.md
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

  s.extra_rdoc_files = %w[LICENSE.txt AUTHORS]
  s.add_dependency 'kramdown',              '>= 2.1'
  s.add_dependency 'kramdown-parser-gfm',   '>= 1.0.1'
  s.add_dependency 'mustache',              '>= 0.7.0'
  # nokogiri <= 1.14.2 mishandle tag names with ":" in them (see #102)
  s.add_dependency 'nokogiri',              '>= 1.14.3'
  # rack < 2.2.3.0 have security vulns
  s.add_development_dependency 'rack',      '>= 2.2.3'
  s.add_development_dependency 'rake',      '>= 13.0.3'
  # just a guess based on what I used to use
  s.add_development_dependency 'rubocop',   '>= 1.25.1'
  s.add_development_dependency 'rubocop-rake'
  # sinatra < 2.2.3 have security vulns
  s.add_development_dependency 'sinatra',   '>= 2.2.3'
  s.add_development_dependency 'test-unit', '>= 3.2.7'

  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Ronn']
  s.require_paths = %w[lib]
end
