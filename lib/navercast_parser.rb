require 'nokogiri'
require 'open-uri'
require 'ostruct'

class NavercastParser
  NAVER_CAST_BASE_URI = 'http://terms.naver.com'

  def self.fetch_data(cid, category_id)
    Rails.logger.info("fetch_data: #{cid}")

    list_url = "#{NAVER_CAST_BASE_URI}/list.nhn?cid=#{cid}&categoryId=#{category_id}"
    puts "LIST_URL: #{list_url}"
    doc = Nokogiri::HTML(open(list_url))
    feed_title = doc.css('title').first.text
    puts "FEED_TITLE: #{feed_title}"
    items = []
    doc.css('ul.thmb_lst dl').lazy.first(15).each do |link|
      item = OpenStruct.new
      item.title = Rails::Html::FullSanitizer.new.sanitize(
        "#{link.css('dt a strong').text}"
      )
      item.link = NAVER_CAST_BASE_URI + link.css('a').attr('href')

      doc = Nokogiri::HTML(open(item.link))
      article_link = doc.css('div#content').first
      Rails.logger.debug "article_link: #{article_link}"
      parsed_obj = article_link
      datetime = article_link.css('div.box_regard ul li').last&.text
      Time.strptime(datetime, '%Y. %m. %d').utc.strftime('%FT%T%z') rescue Time.now.utc.strftime('%FT%T%z')

      item.summary = parsed_obj.to_html
      items << item
    end
    feed_data = OpenStruct.new
    feed_data.title = feed_data.about = feed_title
    Rails.logger.info("item count: #{items.size}, feed_data: #{feed_data.inspect}")
    [items, feed_data]
  end

  def self.report_google_analytics(cid, feed_title, ua)
    RestClient.post('http://www.google-analytics.com/collect',
      {
        v: '1',
        tid: 'UA-87999219-1',
        cid: SecureRandom.uuid,
        t: 'pageview',
        dh: 'navercast.petabytes.org',
        dp: cid.to_s,
        dt: feed_title,
      },
      user_agent: ua
    )
  end
end
