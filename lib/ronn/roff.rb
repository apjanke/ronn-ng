require 'nokogiri'
require 'ronn/utils'

module Ronn
  # Filter for converting HTML to ROFF
  class RoffFilter
    include Ronn::Utils

    # Convert Ronn HTML to roff.
    # The html input is an HTML fragment, not a complete document
    def initialize(html_fragment, name, section, tagline, manual = nil,
                   version = nil, date = nil)
      @buf = []
      title_heading name, section, tagline, manual, version, date
      doc = Nokogiri::HTML.fragment(html_fragment)
      remove_extraneous_elements! doc
      normalize_whitespace! doc
      block_filter doc
      write "\n"
    end

    def to_s
      @buf.join.gsub(/[ \t]+$/, '')
    end

    protected

    def previous(node)
      return unless node.respond_to?(:previous)
      prev = node.previous
      prev = prev.previous until prev.nil? || prev.elem?
      prev
    end

    def title_heading(name, section, _tagline, manual, version, date)
      comment "generated with Ronn-NG/v#{Ronn.version}"
      comment "http://github.com/apjanke/ronn-ng/tree/#{Ronn.revision}"
      return if name.nil?
      if manual
        macro 'TH', %("#{escape(name.upcase)}" "#{section}" "#{date.strftime('%B %Y')}" "#{version}" "#{manual}")
      else
        macro 'TH', %("#{escape(name.upcase)}" "#{section}" "#{date.strftime('%B %Y')}" "#{version}")
      end
    end

    def remove_extraneous_elements!(doc)
      doc.traverse do |node|
        node.parent.children.delete(node) if node.comment?
      end
    end

    def normalize_whitespace!(node)
      if node.is_a?(Array) || node.is_a?(Nokogiri::XML::NodeSet)
        node.to_a.dup.each { |ch| normalize_whitespace! ch }
      elsif node.text?
        preceding = node.previous
        following = node.next
        content = node.content.gsub(/[\n ]+/m, ' ')
        if preceding.nil? || block_element?(preceding.name) ||
           preceding.name == 'br'
          content.lstrip!
        end
        if following.nil? || block_element?(following.name) ||
           following.name == 'br'
          content.rstrip!
        end
        if content.empty?
          node.remove
        else
          node.content = content
        end
      elsif node.elem? && node.name == 'pre'
        # stop traversing
      elsif node.elem? && node.children
        normalize_whitespace! node.children
      elsif node.elem?
        # element has no children
      elsif node.document? || node.fragment?
        normalize_whitespace! node.children
      elsif node.is_a?(Nokogiri::XML::DTD) || node.is_a?(Nokogiri::XML::Comment)
        # ignore
        nop
      else
        warn 'unexpected node during whitespace normalization: %p', node
      end
    end

    def block_filter(node)
      return if node.nil?

      if node.is_a?(Array) || node.is_a?(Nokogiri::XML::NodeSet)
        node.each { |ch| block_filter(ch) }

      elsif node.document? || node.fragment?
        block_filter(node.children)

      elsif node.text?
        # This hack is necessary to support mixed-child-type dd's
        inline_filter(node)

      elsif node.elem?
        case node.name
        when 'html', 'body'
          block_filter(node.children)
        when 'div'
          block_filter(node.children)
        when 'h1'
          # discard
          nop
        when 'h2'
          macro 'SH', quote(escape(node.inner_html))
        when 'h3'
          macro 'SS', quote(escape(node.inner_html))

        when 'p'
          prev = previous(node)
          if prev && %w[dd li blockquote].include?(node.parent.name)
            macro 'IP'
          elsif prev && !%w[h1 h2 h3].include?(prev.name)
            macro 'P'
          elsif node.previous&.text?
            macro 'IP'
          end
          inline_filter(node.children)

        when 'blockquote'
          prev = previous(node)
          indent = prev.nil? || !%w[h1 h2 h3].include?(prev.name)
          macro 'IP', %w["" 4] if indent
          block_filter(node.children)
          macro 'IP', %w["" 0] if indent

        when 'pre'
          prev = previous(node)
          indent = prev.nil? || !%w[h1 h2 h3].include?(prev.name)
          macro 'IP', %w["" 4] if indent
          macro 'nf'
          # HACK: strip an initial \n to avoid extra spacing
          if node.children && node.children[0].text?
            text = node.children[0].to_s
            node.children[0].replace(text[1..-1]) if text.start_with? "\n"
          end
          inline_filter(node.children)
          macro 'fi'
          macro 'IP', %w["" 0] if indent

        when 'dl'
          macro 'TP'
          block_filter(node.children)
        when 'dt'
          prev = previous(node)
          macro 'TP' unless prev.nil?
          inline_filter(node.children)
          write "\n"
        when 'dd'
          if node.at('p')
            block_filter(node.children)
          else
            inline_filter(node.children)
          end
          write "\n"

        when 'ol', 'ul'
          block_filter(node.children)
          macro 'IP', %w["" 0]
        when 'li'
          case node.parent.name
          when 'ol'
            macro 'IP', %W["#{node.parent.children.index(node) + 1}." 4]
          when 'ul'
            macro 'IP', ['"\\[ci]"', '4']
          else
            raise "List element found as a child of non-list parent element: #{node.inspect}"
          end
          if node.at('p,ol,ul,dl,div')
            block_filter(node.children)
          else
            inline_filter(node.children)
          end
          write "\n"

        when 'span', 'code', 'b', 'strong', 'kbd', 'samp', 'var', 'em', 'i',
             'u', 'br', 'a'
          inline_filter(node)

        when 'table'
          macro 'TS'
          write "allbox;\n"
          block_filter(node.children)
          macro 'TE'
        when 'thead'
          # Convert to format section and first row
          tr = node.children[0]
          header_contents = []
          cell_formats = []
          tr.children.each do |th|
            style = th['style']
            cell_format = case style
                          when 'text-align:left;'
                            'l'
                          when 'text-align:right;'
                            'r'
                          when 'text-align:center;'
                            'c'
                          else
                            'l'
                          end
            header_contents << th.inner_html
            cell_formats << cell_format
          end
          write cell_formats.join(' ') + ".\n"
          write header_contents.join("\t") + "\n"
        when 'th'
          raise 'internal error: unexpected <th> element'
        when 'tbody'
          # Let the 'tr' handle it
          block_filter(node.children)
        when 'tr'
          # Convert to a table data row
          node.children.each do |child|
            block_filter(child)
            write "\t"
          end
          write "\n"
        when 'td'
          inline_filter(node.children)

        else
          warn 'unrecognized block tag: %p', node.name
        end

      elsif node.is_a?(Nokogiri::XML::DTD)
        # Ignore
        nop
      elsif node.is_a?(Nokogiri::XML::Comment)
        # Ignore
        nop
      else
        raise "unexpected node: #{node.inspect}"
      end
    end

    def inline_filter(node)
      return unless node # is an empty node

      if node.is_a?(Array) || node.is_a?(Nokogiri::XML::NodeSet)
        node.each { |ch| inline_filter(ch) }

      elsif node.text?
        text = node.to_html.dup
        write escape(text)

      elsif node.elem?
        case node.name
        when 'span'
          inline_filter(node.children)
        when 'code'
          if child_of?(node, 'pre')
            inline_filter(node.children)
          else
            write '\fB'
            inline_filter(node.children)
            write '\fR'
          end

        when 'b', 'strong', 'kbd', 'samp'
          write '\fB'
          inline_filter(node.children)
          write '\fR'

        when 'var', 'em', 'i', 'u'
          write '\fI'
          inline_filter(node.children)
          write '\fR'

        when 'br'
          macro 'br'

        when 'a'
          if node.classes.include?('man-ref')
            inline_filter(node.children)
          elsif node.has_attribute?('data-bare-link')
            write '\fI'
            inline_filter(node.children)
            write '\fR'
          else
            inline_filter(node.children)
            write ' '
            write '\fI'
            write escape(node.attributes['href'].content)
            write '\fR'
          end

        when 'sup'
          # This superscript equivalent is a big ugly hack.
          write '^('
          inline_filter(node.children)
          write ')'

        else
          warn 'unrecognized inline tag: %p', node.name
        end

      else
        raise "unexpected node: #{node.inspect}"
      end
    end

    def maybe_new_line
      write "\n" if @buf.last && @buf.last[-1] != "\n"
    end

    def macro(name, value = nil)
      maybe_new_line
      writeln ".#{[name, value].compact.join(' ')}"
    end

    HTML_ROFF_ENTITIES = {
      '•' => '\[ci]',
      '&lt;' => '<',
      '&gt;' => '>',
      ' ' => '\~', # That's a literal non-breaking space character there
      '©' => '\(co',
      '”' => '\(rs',
      '—' => '\(em',
      '®' => '\(rg',
      '§' => '\(sc',
      '≥' => '\(>=',
      '≤' => '\(<=',
      '≠' => '\(!=',
      '≡' => '\(=='
    }.freeze

    def escape(text)
      return text.to_s if text.nil? || text.empty?
      ent = HTML_ROFF_ENTITIES
      text = text.dup
      text.gsub!(/&#x([0-9A-Fa-f]+);/) { $1.to_i(16).chr }  # hex entities
      text.gsub!(/&#(\d+);/) { $1.to_i.chr }                # dec entities
      text.gsub!('\\', '\e')                                # backslash
      text.gsub!('...', '\|.\|.\|.')                        # ellipses
      text.gsub!(/['.-]/) { |m| "\\#{m}" }                  # control chars
      ent.each do |key, val|
        text.gsub!(key, val)
      end
      text.gsub!('&amp;', '&')                              # amps
      text
    end

    def quote(text)
      "\"#{text.gsub(/"/, '\\"')}\""
    end

    # write text to output buffer
    def write(text)
      return if text.nil? || text.empty?
      # lines cannot start with a '.'. insert zero-width character before.
      text = text.gsub(/\n\\\./, "\n\\\\&\\.")
      buf_ends_in_newline = @buf.last && @buf.last[-1] == "\n"
      @buf << '\&' if text[0, 2] == '\.' && buf_ends_in_newline
      @buf << text
    end

    # write text to output buffer on a new line.
    def writeln(text)
      maybe_new_line
      write text
      write "\n"
    end

    def comment(text)
      writeln %(.\\" #{text})
    end

    def warn(text, *args)
      Kernel.warn format("warn: #{text}", args)
    end

    def nop
      # Do nothing
    end
  end
end
