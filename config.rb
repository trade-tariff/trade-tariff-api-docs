# frozen_string_literal: true

require 'govuk_tech_docs'
require 'kramdown'

GovukTechDocs.configure(self)

# Project layout partials in source/layouts/ must override the gem's lib/source/layouts/
# (the gem registers its source directory after ours with the same default priority).
files.watch :source, path: File.join(root, 'source'), priority: 100

activate :relative_assets
set :relative_links, true

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
