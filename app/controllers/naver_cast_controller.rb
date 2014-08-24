require 'naver_cast_parser'
require 'rss'

class NaverCastController < ApplicationController
  def index
    data = fetch_data(CAST_INFO[:it])
    rss = RSS::Maker.make('atom') do |maker|
      maker.channel.author = "Benjamin"
      maker.channel.about = CAST_INFO[:it][:title]
      maker.channel.title = CAST_INFO[:it][:title]

      data.each do |x|
        maker.items.new_item do |item|
          item.link = x.link
          item.title = x.title
          item.updated = x.updated
          item.summary = x.summary
        end
      end

      maker.channel.updated = maker.items.max_by {|x| x.updated}.updated
    end

    render xml: rss.to_xml
  end

  # FIXME: 코드 짤수 있는 환경이 아니어서 그냥 복사해버렸다.
  def method_dic
    data = fetch_data(CAST_INFO[:method_dic])
    rss = RSS::Maker.make('atom') do |maker|
      maker.channel.author = "Benjamin"
      maker.channel.about = CAST_INFO[:method_dic][:title]
      maker.channel.title = CAST_INFO[:method_dic][:title]

      data.each do |x|
        maker.items.new_item do |item|
          item.link = x.link
          item.title = x.title
          item.updated = x.updated
          item.summary = x.summary
        end
      end

      maker.channel.updated = maker.items.max_by {|x| x.updated}.updated
    end

    render xml: rss.to_xml
  end
end
