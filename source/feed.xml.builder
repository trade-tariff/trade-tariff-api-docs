# frozen_string_literal: true

xml.instruct!
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do
  site_domain = 'api.trade-tariff.service.gov.uk'
  site_url = "https://#{site_domain}/"

  xml.id "tag:#{site_domain},2005:/News"
  xml.link 'href' => URI.join(site_url, '/news.html'),
           'rel' => 'alternate',
           'type' => 'text/html'
  xml.link 'href' => URI.join(site_url, '/feed.xml'),
           'rel' => 'self',
           'type' => 'application/atom+xml'
  xml.title 'Online Trade Tariff API'
  xml.subtitle 'API News'
  xml.updated data.news.map(&:date).max.to_time.iso8601 unless data.news.empty?

  data.news.sort_by(&:date).each do |news_item|
    xml.entry do
      xml.id "tag:#{site_domain},2005:News/#{news_item.date.strftime('%Y-%m-%d')}"
      xml.link 'rel' => 'alternate', 'href' => URI.join(site_url, '/news.html')
      xml.title news_item.title
      xml.content news_item.content
      xml.published news_item.date.to_time.iso8601
      xml.updated news_item.date.to_time.iso8601
      xml.author do
        xml.name 'Online Trade Tariff'
      end
    end
  end
end
