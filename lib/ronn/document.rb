require 'time'
require 'cgi'
require 'nokogiri'
require 'kramdown'
require 'ronn/index'
require 'ronn/roff'
require 'ronn/template'
require 'ronn/utils'

module Ronn
  # The Document class can be used to load and inspect a ronn document
  # and to convert a ronn document into other formats, like roff or
  # HTML.
  #
  # Ronn files may optionally follow the naming convention:
  # "<name>.<section>.ronn". The <name> and <section> are used in
  # generated documentation unless overridden by the information
  # extracted from the document's name section.
  class Document
    include Ronn::Utils

    # Path to the Ronn document. This may be '-' or nil when the Ronn::Document
    # object is created with a stream, in which case stdin will be read.
    attr_reader :path

    # Encoding that the Ronn document is in
    attr_accessor :encoding

    # The raw input data, read from path or stream and unmodified.
    attr_reader :data

    # The index used to resolve man and file references.
    attr_accessor :index

    # The man pages name: usually a single word name of
    # a program or filename; displayed along with the section in
    # the left and right portions of the header as well as the bottom
    # right section of the footer.
    attr_writer :name

    # The man page's section: a string whose first character
    # is numeric; displayed in parenthesis along with the name.
    attr_writer :section

    # Single sentence description of the thing being described
    # by this man page; displayed in the NAME section.
    attr_accessor :tagline

    # The manual this document belongs to; center displayed in
    # the header.
    attr_accessor :manual

    # The name of the group, organization, or individual responsible
    # for this document; displayed in the left portion of the footer.
    attr_accessor :organization

    # The date the document was published; center displayed in
    # the document footer.
    attr_writer :date

    # Array of style modules to apply to the document.
    attr_reader :styles

    # Output directory to write files to.
    attr_accessor :outdir

    # Create a Ronn::Document given a path or with the data returned by
    # calling the block. The document is loaded and preprocessed before
    # the intialize method returns. The attributes hash may contain values
    # for any writeable attributes defined on this class.
    def initialize(path = nil, attributes = {}, &block)
      @path = path
      @basename = path.to_s =~ /^-?$/ ? nil : File.basename(path)
      @reader = block ||
                lambda do |f|
                  if ['-', nil].include?(f)
                    STDIN.read
                  else
                    File.read(f, encoding: @encoding)
                  end
                end
      @data = @reader.call(path)
      @name, @section, @tagline = sniff

      @styles = %w[man]
      @manual, @organization, @date = nil
      @markdown, @input_html, @html = nil
      @index = Ronn::Index[path || '.']
      @index.add_manual(self) if path && name

      attributes.each { |attr_name, value| send("#{attr_name}=", value) }
    end

    # Generate a file basename of the form "<name>.<section>.<type>"
    # for the given file extension. Uses the name and section from
    # the source file path but falls back on the name and section
    # defined in the document.
    def basename(type = nil)
      type = nil if ['', 'roff'].include?(type.to_s)
      [path_name || @name, path_section || @section, type]
        .compact.join('.')
    end

    # Construct a path for a file near the source file. Uses the
    # Document#basename method to generate the basename part and
    # appends it to the dirname of the source document.
    def path_for(type = nil)
      if @outdir
        File.join(@outdir, basename(type))
      elsif @basename
        File.join(File.dirname(path), basename(type))
      else
        basename(type)
      end
    end

    # Returns the <name> part of the path, or nil when no path is
    # available. This is used as the manual page name when the
    # file contents do not include a name section.
    def path_name
      return unless @basename

      parts = @basename.split('.')
      parts.pop if parts.length > 1 && parts.last =~ /^\w+$/
      parts.pop if parts.last =~ /^\d+$/
      parts.join('.')
    end

    # Returns the <section> part of the path, or nil when
    # no path is available.
    def path_section
      $1 if @basename.to_s =~ /\.(\d\w*)\./
    end

    # Returns the manual page name based first on the document's
    # contents and then on the path name. Usually a single word name of
    # a program or filename; displayed along with the section in
    # the left and right portions of the header as well as the bottom
    # right section of the footer.
    def name
      @name || path_name
    end

    # Truthful when the name was extracted from the name section
    # of the document.
    def name?
      !@name.nil?
    end

    # Returns the manual page section based first on the document's
    # contents and then on the path name. A string whose first character
    # is numeric; displayed in parenthesis along with the name.
    def section
      @section || path_section
    end

    # True when the section number was extracted from the name
    # section of the document.
    def section?
      !@section.nil?
    end

    # The name used to reference this manual.
    def reference_name
      name + (section && "(#{section})").to_s
    end

    # Truthful when the document started with an h1 but did not follow
    # the "<name>(<sect>) -- <tagline>" convention. We assume this is some kind
    # of custom title.
    def title?
      !name? && tagline
    end

    # The document's title when no name section was defined. When a name section
    # exists, this value is nil.
    def title
      @tagline unless name?
    end

    # The date the man page was published. If not set explicitly,
    # this is the file's modified time or, if no file is given,
    # the current time. Center displayed in the document footer.
    def date
      return @date if @date

      return File.mtime(path) if File.exist?(path)

      Time.now
    end

    # Retrieve a list of top-level section headings in the document and return
    # as an array of +[id, text]+ tuples, where +id+ is the element's generated
    # id and +text+ is the inner text of the heading element.
    def toc
      @toc ||=
        html.search('h2[@id]').map { |h2| [h2.attributes['id'].content.upcase, h2.inner_text] }
    end
    alias section_heads toc

    # Styles to insert in the generated HTML output. This is a simple Array of
    # string module names or file paths.
    def styles=(styles)
      @styles = (%w[man] + styles).uniq
    end

    # Sniff the document header and extract basic document metadata. Return a
    # tuple of the form: [name, section, description], where missing information
    # is represented by nil and any element may be missing.
    def sniff
      html = Kramdown::Document.new(data[0, 512], auto_ids: false, smart_quotes: ['apos', 'apos', 'quot', 'quot'], typographic_symbols: { hellip: '...', ndash: '--', mdash: '--' }).to_html
      heading, html = html.split("</h1>\n", 2)
      return [nil, nil, nil] if html.nil?

      case heading
      when /([\w_.\[\]~+=@:-]+)\s*\((\d\w*)\)\s*-+\s*(.*)/
        # name(section) -- description
        [$1, $2, $3]
      when /([\w_.\[\]~+=@:-]+)\s+-+\s+(.*)/
        # name -- description
        [$1, nil, $2]
      else
        # description
        [nil, nil, heading.sub('<h1>', '')]
      end
    end

    # Preprocessed markdown input text.
    def markdown
      @markdown ||= process_markdown!
    end

    # A Nokogiri DocumentFragment for the manual content fragment.
    def html
      @html ||= process_html!
    end

    # Convert the document to :roff, :html, or :html_fragment and
    # return the result as a string.
    def convert(format)
      send "to_#{format}"
    end

    # Convert the document to roff and return the result as a string.
    def to_roff
      RoffFilter.new(
        to_html_fragment(nil),
        name, section, tagline,
        manual, organization, date
      ).to_s
    end

    # Convert the document to HTML and return the result as a string.
    # The returned string is a complete HTML document.
    def to_html
      layout = ENV['RONN_LAYOUT']
      layout_path = nil
      if layout
        layout_path = File.expand_path(layout)
        unless File.exist?(layout_path)
          warn "warn: can't find #{layout}, using default layout."
          layout_path = nil
        end
      end

      template = Ronn::Template.new(self)
      template.context.push html: to_html_fragment(nil)
      template.render(layout_path || 'default')
    end

    # Convert the document to HTML and return the result
    # as a string. The HTML does not include <html>, <head>,
    # or <style> tags.
    def to_html_fragment(wrap_class = 'mp')
      frag_nodes = html.at('body').children
      out = frag_nodes.to_s.rstrip
      out = "<div class='#{wrap_class}'>#{out}\n</div>" unless wrap_class.nil?
      out
    end

    def to_markdown
      markdown
    end

    def to_h
      %w[name section tagline manual organization date styles toc]
        .each_with_object({}) { |name, hash| hash[name] = send(name) }
    end

    def to_yaml
      require 'yaml'
      to_h.to_yaml
    end

    def to_json(*_args)
      require 'json'
      to_h.merge('date' => date.iso8601).to_json
    end

    protected

    ##
    # Document Processing

    # Parse the document and extract the name, section, and tagline from its
    # contents. This is called while the object is being initialized.
    def preprocess!
      input_html
      nil
    end

    def input_html
      @input_html ||= strip_heading(Kramdown::Document.new(markdown, auto_ids: false, smart_quotes: ['apos', 'apos', 'quot', 'quot'], typographic_symbols: { hellip: '...', ndash: '--', mdash: '--' }).to_html)
    end

    def strip_heading(html)
      heading, html = html.split("</h1>\n", 2)
      html || heading
    end

    def process_markdown!
      md = markdown_filter_heading_anchors(data)
      md = markdown_filter_link_index(md)
      markdown_filter_angle_quotes(md)
    end

    def process_html!
      wrapped_html = "<html>\n  <body>\n#{input_html}\n  </body>\n</html>"
      @html = Nokogiri::HTML.parse(wrapped_html)
      html_filter_angle_quotes
      html_filter_definition_lists
      html_filter_inject_name_section
      html_filter_heading_anchors
      html_filter_annotate_bare_links
      html_filter_manual_reference_links
      @html
    end

    ##
    # Filters

    # Appends all index links to the end of the document as Markdown reference
    # links. This lets us use [foo(3)][] syntax to link to index entries.
    def markdown_filter_link_index(markdown)
      return markdown if index.nil? || index.empty?

      markdown << "\n\n"
      index.each { |ref| markdown << "[#{ref.name}]: #{ref.url}\n" }
      markdown
    end

    # Add [id]: #ANCHOR elements to the markdown source text for all sections.
    # This lets us use the [SECTION-REF][] syntax
    def markdown_filter_heading_anchors(markdown)
      first = true
      markdown.split("\n").grep(/^[#]{2,5} +[\w '-]+[# ]*$/).each do |line|
        markdown << "\n\n" if first
        first = false
        title = line.gsub(/[^\w -]/, '').strip
        anchor = title.gsub(/\W+/, '-').gsub(/(^-+|-+$)/, '')
        markdown << "[#{title}]: ##{anchor} \"#{title}\"\n"
      end
      markdown
    end

    # Convert <WORD> to <var>WORD</var> but only if WORD isn't an HTML tag.
    def markdown_filter_angle_quotes(markdown)
      markdown.gsub(/<([^:.\/]+?)>/) do |match|
        contents = $1
        tag, attrs = contents.split(' ', 2)
        if attrs =~ /\/=/ || html_element?(tag.sub(/^\//, '')) ||
           data.include?("</#{tag}>") || contents =~ /^!/
          match.to_s
        else
          "<var>#{contents}</var>"
        end
      end
    end

    # Perform angle quote (<THESE>) post filtering.
    def html_filter_angle_quotes
      # convert all angle quote vars nested in code blocks
      # back to the original text
      code_nodes = @html.search('code')
      code_nodes.search('.//text() | text()').each do |node|
        next unless node.to_html.include?('var&gt;')

        new =
          node.to_html
              .gsub('&lt;var&gt;', '&lt;')
              .gsub('&lt;/var&gt;', '>')
        node.swap(new)
      end
    end

    # Convert special format unordered lists to definition lists.
    def html_filter_definition_lists
      # process all unordered lists depth-first
      @html.search('ul').to_a.reverse_each do |ul|
        items = ul.search('li')
        next if items.any? { |item| item.inner_text.strip.split("\n", 2).first !~ /:$/ }

        dl = Nokogiri::XML::Node.new 'dl', html
        items.each do |item|
          # This processing is specific to how Markdown generates definition lists
          term, definition = item.inner_html.strip.split(":\n", 2)
          term = term.sub(/^<p>/, '')

          dt = Nokogiri::XML::Node.new 'dt', html
          dt.children = Nokogiri::HTML.fragment(term)
          dt.attributes['class'] = 'flush' if dt.inner_text.length <= 7

          dd = Nokogiri::XML::Node.new 'dd', html
          dd_contents = Nokogiri::HTML.fragment(definition)
          dd.children = dd_contents

          dl.add_child(dt)
          dl.add_child(dd)
        end
        ul.replace(dl)
      end
    end

    def html_filter_inject_name_section
      markup =
        if title?
          "<h1>#{title}</h1>"
        elsif name
          "<h2>NAME</h2>\n" \
            "<p class='man-name'>\n  <code>#{name}</code>" +
            (tagline ? " - <span class='man-whatis'>#{tagline}</span>\n" : "\n") +
            "</p>\n"
        end
      return unless markup

      if html.at('body').first_element_child
        html.at('body').first_element_child.before(Nokogiri::HTML.fragment(markup))
      else
        html.at('body').add_child(Nokogiri::HTML.fragment(markup))
      end
    end

    # Add URL anchors to all HTML heading elements.
    def html_filter_heading_anchors
      h_nodes = @html.search('//*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5 and not(@id)]')
      h_nodes.each do |heading|
        heading.set_attribute('id', heading.inner_text.gsub(/\W+/, '-'))
      end
    end

    # Add a 'data-bare-link' attribute to hyperlinks
    # whose text labels are the same as their href URLs.
    def html_filter_annotate_bare_links
      @html.search('a[@href]').each do |node|
        href = node.attributes['href'].content
        text = node.inner_text

        next unless href == text || href[0] == '#' ||
                    CGI.unescapeHTML(href) == "mailto:#{CGI.unescapeHTML(text)}"

        node.set_attribute('data-bare-link', 'true')
      end
    end

    # Convert text of the form "name(section)" or "<code>name</code>(section)
    # to a hyperlink.  The URL is obtained from the index.
    def html_filter_manual_reference_links
      return if index.nil?

      name_pattern = '[0-9A-Za-z_:.+=@~-]+'

      # Convert "name(section)" by traversing text nodes searching for
      # text that fits the pattern.  This is the original implementation.
      @html.search('.//text() | text()').each do |node|
        next unless node.content.include?(')')
        next if %w[pre code h1 h2 h3].include?(node.parent.name)
        next if child_of?(node, 'a')
        node.swap(node.content.gsub(/(#{name_pattern})(\(\d+\w*\))/) do
          html_build_manual_reference_link($1, $2)
        end)
      end

      # Convert "<code>name</code>(section)" by traversing <code> nodes.
      # For each one that contains exactly an acceptable manual page name,
      # the next sibling is checked and must be a text node beginning
      # with a valid section in parentheses.
      @html.search('code').each do |node|
        next if %w[pre code h1 h2 h3].include?(node.parent.name)
        next if child_of?(node, 'a')
        next unless node.inner_text =~ /^#{name_pattern}$/
        sibling = node.next
        next unless sibling
        next unless sibling.text?
        next unless sibling.content =~ /^\((\d+\w*)\)/
        node.swap(html_build_manual_reference_link(node, "(#{$1})"))
        sibling.content = sibling.content.gsub(/^\(\d+\w*\)/, '')
      end
    end

    # HTMLize the manual page reference.  The result is an <a> if the
    # page appears in the index, otherwise it is a <span>.  The first
    # argument may be an HTML element or a string.  The second should
    # be a string of the form "(#{section})".
    def html_build_manual_reference_link(name_or_node, section)
      name = if name_or_node.respond_to?(:inner_text)
               name_or_node.inner_text
             else
               name_or_node
             end
      ref = index["#{name}#{section}"]
      if ref
        "<a class='man-ref' href='#{ref.url}'>#{name_or_node}<span class='s'>#{section}</span></a>"
      else
        # warn "warn: manual reference not defined: '#{name}#{section}'"
        "<span class='man-ref'>#{name_or_node}<span class='s'>#{section}</span></span>"
      end
    end
  end
end
