xml.instruct!
xml.feed "xmlns" => "http://www.w3.org/2005/Atom" do
  site_domain = "api.trade-tariff.service.gov.uk"
  site_url = "https://#{site_domain}/"

  xml.id "tag:site_domain,2005:/News"
  xml.link 'href' => URI.join(site_url, '/news.html'),
           'rel' => 'alternate',
           'type' => 'text/html'
  xml.link 'href' => URI.join(site_url, '/feed.xml'),
           'rel' => 'self',
           'type' => 'application/atom+xml'
  xml.title "Online Trade Tariff API"
  xml.subtitle "API News"
  xml.updated data.news.map(&:date).max.iso8601 unless data.news.empty?

  data.news.each do |news_item|
    xml.entry do
      xml.id "tag:#{site_domain},2005:News/#{news_item.date.strftime('%Y-%m-%d')}"
      xml.link "rel" => "alternate", "href" => URI.join(site_url, '/news.html')
      xml.title news_item.title
      xml.content news_item.content
      xml.published news_item.date.iso8601
      xml.updated news_item.date.iso8601
    end
  end
end
