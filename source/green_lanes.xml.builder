# frozen_string_literal: true

xml.instruct!
xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do
  site_domain = 'api.trade-tariff.service.gov.uk'
  site_url = "https://#{site_domain}/"

  xml.id "tag:#{site_domain},2005:/GreenLanesApi"
  xml.link 'href' => URI.join(site_url, '/categorisation.html'),
           'rel' => 'alternate',
           'type' => 'text/html'
  xml.link 'href' => URI.join(site_url, '/categorisation.xml'),
           'rel' => 'self',
           'type' => 'application/atom+xml'
  xml.title 'Online Trade Tariff API'
  xml.subtitle 'Green Lanes API changes'
  xml.updated data.green_lanes_changes.map(&:date).max.to_time.iso8601 unless data.green_lanes_changes.empty?

  data.green_lanes_changes.sort_by(&:date).each do |change|
    xml.entry do
      xml.id "tag:#{site_domain},2005:GreenLanesApi/#{change.date.strftime('%Y-%m-%d')}"
      xml.link 'rel' => 'alternate', 'href' => URI.join(site_url, '/categorisation.html')
      xml.title change.date.strftime('%D %b %Y')
      xml.content change.content
      xml.published change.date.to_time.iso8601
      xml.updated change.date.to_time.iso8601
      xml.author do
        xml.name 'Online Trade Tariff'
      end
    end
  end
end
