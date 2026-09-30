require 'contest'
require 'ronn/document'
require 'ronn/template'

class TemplateTest < Test::Unit::TestCase
  SIMPLE_FILE = "#{File.dirname(__FILE__)}/basic_document.ronn".freeze

  def document
    Ronn::Document.new(SIMPLE_FILE)
  end

  test 'style path is a flat list of directory strings' do
    template = Ronn::Template.new(document, ['/tmp/styles'])
    assert template.style_path.all? { |p| p.is_a?(String) },
           "non-String entries in style_path: #{template.style_path.inspect}"
  end

  test 'style path includes the bundled template directory' do
    template = Ronn::Template.new(document, [])
    assert template.style_path.include?(Array(Ronn::Template.template_path).first),
           "template_path missing from style_path: #{template.style_path.inspect}"
  end

  test 'style files resolves the bundled man style' do
    template = Ronn::Template.new(document, [])
    assert_equal 1, template.style_files.size
    assert template.style_files.first.end_with?('/man.css')
    assert File.exist?(template.style_files.first)
  end

  test 'to html renders a complete document' do
    html = document.to_html
    assert_match(/<!DOCTYPE html>/, html)
    assert_match(%r{<title>.+</title>}, html)
    assert_match(/style: man/, html)
  end
end
