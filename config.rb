# frozen_string_literal: true

require 'govuk_tech_docs'
require 'kramdown'

GovukTechDocs.configure(self)

# Project layout partials in source/layouts/ must override the gem's lib/source/layouts/
# (the gem registers its source directory after ours with the same default priority).
files.watch :source, path: File.join(root, 'source'), priority: 100

activate :relative_assets
set :relative_links, true

ignore '/templates/raw_markdown_page.txt'

ready do
  source_root = File.join(root, 'source')

  Dir.glob(File.join(source_root, '**', '*.html.md{,.erb}'))
    .reject { |f| f.start_with?(File.join(source_root, 'layouts')) }
    .each do |source_file|
      content = File.read(source_file, encoding: 'utf-8')
      content = content.sub(/\A---\n.*?\n---\n/m, '')
      content = content.gsub(/<%.*?%>\n?/m, '')
      content = strip_html(content)
      content = content.gsub(/\n{3,}/, "\n\n").strip + "\n"

      relative = source_file.delete_prefix("#{source_root}/")
      md_path = '/' + relative.sub(/\.html\.md(\.erb)?$/, '.md')

      proxy md_path, '/templates/raw_markdown_page.txt', locals: { markdown_content: content }, layout: false
    end
end

def strip_html(content)
  # <a href="...">text</a> → [text](href)
  content = content.gsub(/<a\s[^>]*href="([^"]*)"[^>]*>(.*?)<\/a>/m) do
    href, text = $1, $2.gsub(/<[^>]+>/, '').strip
    "[#{text}](#{href})"
  end
  # <code>text</code> → `text`
  content = content.gsub(/<code>(.*?)<\/code>/m) { "`#{$1.strip}`" }
  # Strip all remaining HTML tags and any lines that become blank
  content.gsub(/<[^>]*>/m, '')
end

helpers do
  def graphviz(graph_file = nil, &block)
    if block_given?
      data = capture_html(&block)
    elsif graph_file
      data = File.read("source/graphviz/#{graph_file.sub(/\.dot$/, '')}.dot")
    else
      return
    end

    out, _, _status = Open3.capture3('dot -Tsvg', stdin_data: data)
    svg = out.gsub(/.*<svg/m, '<svg').gsub(/\n/m, '').html_safe

    concat_content(svg.html_safe)
  end

  def convert_markdown(markdown_content)
    ::Kramdown::Document.new(markdown_content).to_html
  end
end
