require 'nokogiri'
require 'open-uri'
require 'ostruct'

NAVER_CAST_BASE_URI = 'http://navercast.naver.com'
CAST_INFO = {
  it: {
    cid: 122,
    title: '네이버캐스트 IT 이야기'
  },
  method_dic: {
    cid: 112,
    title: '네이버 방법사전'
  },
}

def fetch_data(cast_info_h)
  doc = Nokogiri::HTML(open("#{NAVER_CAST_BASE_URI}/list.nhn?cid=#{cast_info_h[:cid]}&category_id=#{cast_info_h[:cid]}"))
  items = []
  doc.css('ul.card_lst div.card_w').each do |link|
    item = OpenStruct.new
    item.title = HTML::FullSanitizer.new.sanitize(link.css('span.info').text)
    item.link = NAVER_CAST_BASE_URI + link.css('a').attr('href')

    contents_uri = (NAVER_CAST_BASE_URI + link.css('a[href^="/contents.nhn"]').attr('href')).tap do |uri|
      puts "Content Uri: #{uri}"
    end

    doc = Nokogiri::HTML(open(contents_uri))
    parsed_obj = ''
    article_link = doc.css('div.smarteditor_area.naml_article').first
    puts "article_link: #{article_link}"
    parsed_obj = article_link
    datetime = article_link.css('div.t_pdate span').text
    if datetime.blank?
      item.updated = Time.now.utc.strftime('%FT%T%z')
    else
      item.updated = Time.strptime(datetime, "%Y.%m.%d").utc.strftime('%FT%T%z')
    end

    item.summary = parsed_obj.to_html
    items << item
  end
  items
end
