Gem::Specification.new do |s|
  s.name = 'ronn-ng'
  s.version = '0.9.1'
  s.date = '2020-04-09'

  s.summary     = 'Builds man pages from Markdown'
  s.description = 'Ronn-NG builds manuals in HTML and Unix man page format from Markdown.'
  s.homepage    = 'https://github.com/apjanke/ronn-ng'
  s.license     = 'MIT'

  s.authors     = ['Andrew Janke']
  s.email       = 'floss@apjanke.net'

  s.metadata = {
    'bug_tracker_uri'   => 'https://github.com/apjanke/ronn-ng/issues',
    'source_code_uri'   => 'https://github.com/apjanke/ronn-ng',
    'changelog_uri'     => 'https://github.com/apjanke/ronn-ng/blob/master/CHANGES'
  }

  # = MANIFEST =
  s.files = %w[
    AUTHORS
    CHANGES
    Gemfile
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
    test/angle_bracket_syntax.html
    test/angle_bracket_syntax.ronn
    test/backticks.html
    test/backticks.ronn
    test/basic_document.html
    test/basic_document.ronn
    test/circumflexes.ronn
    test/code_blocks.7.ronn
    test/contest.rb
    test/custom_title_document.html
    test/custom_title_document.ronn
    test/definition_list_syntax.html
    test/definition_list_syntax.roff
    test/definition_list_syntax.ronn
    test/dots_at_line_start_test.roff
    test/dots_at_line_start_test.ronn
    test/ellipses.roff
    test/ellipses.ronn
    test/entity_encoding_test.html
    test/entity_encoding_test.roff
    test/entity_encoding_test.ronn
    test/index.txt
    test/markdown_syntax.html
    test/markdown_syntax.roff
    test/markdown_syntax.ronn
    test/middle_paragraph.html
    test/middle_paragraph.roff
    test/middle_paragraph.ronn
    test/missing_spaces.roff
    test/missing_spaces.ronn
    test/nested_list.ronn
    test/nested_list_with_code.html
    test/nested_list_with_code.roff
    test/nested_list_with_code.ronn
    test/ordered_list.html
    test/ordered_list.roff
    test/ordered_list.ronn
    test/page.with.periods.in.name.5.ronn
    test/pre_block_with_quotes.roff
    test/pre_block_with_quotes.ronn
    test/section_reference_links.html
    test/section_reference_links.roff
    test/section_reference_links.ronn
    test/tables.ronn
    test/test_ronn.rb
    test/test_ronn_document.rb
    test/test_ronn_index.rb
    test/titleless_document.html
    test/titleless_document.ronn
    test/underline_spacing_test.roff
    test/underline_spacing_test.ronn
  ]
  # = MANIFEST =

  s.executables = ['ronn']
  s.test_files = s.files.select { |path| path =~ /^test\/.*_test.rb/ }

  s.extra_rdoc_files = %w[LICENSE.txt AUTHORS]
  s.add_dependency 'kramdown',    '~> 2.1'
  s.add_dependency 'mustache',    '~> 0.7', '>= 0.7.0'
  s.add_dependency 'nokogiri',    '~> 1.9', '>= 1.9.0'
  s.add_development_dependency 'rack',      '~> 2.0',  '>= 2.0.6'
  s.add_development_dependency 'rake',      '~> 12.3', '>= 12.3.0'
  s.add_development_dependency 'rubocop',   '~> 0.60', '>= 0.57.1'
  s.add_development_dependency 'sinatra',   '~> 2.0',  '>= 2.0.0'
  s.add_development_dependency 'test-unit', '~> 3.2',  '>= 3.2.7'

  s.rdoc_options = ['--line-numbers', '--inline-source', '--title', 'Ronn']
  s.require_paths = %w[lib]
end
