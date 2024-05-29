require 'govuk_tech_docs'
require 'kramdown'

GovukTechDocs.configure(self)

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

    out, err, _status = Open3.capture3('dot -Tsvg', stdin_data: data)
    svg = out.gsub(/.*<svg/m, '<svg').gsub(/\n/m, '').html_safe

    concat_content(svg.html_safe)
  end

  def convert_markdown(markdown_content)
    ::Kramdown::Document.new(markdown_content).to_html
  end
end
