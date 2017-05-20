require 'rss'
require 'navercast_parser'

class NaverCastController < ApplicationController
  CACHE_EXPIRING_TIME = Rails.env.production? ? 6.hours : 20.seconds

  def migration_notice
    rss = RSS::Maker.make('atom') do |maker|
      title = '네이버캐스트 개편 공지'.freeze
      updated_at = DateTime.new(2017, 5, 20).utc.strftime('%FT%T%z')
      link = 'https://github.com/BenjaminKim/navercast_rss_feed'.freeze
      maker.channel.author = 'Benjamin'.freeze
      maker.channel.about = link
      maker.channel.title = title

      maker.items.new_item do |item|
        item.link = link
        item.title = title
        item.updated = updated_at
        item.summary = <<~EOS
          <p>
          네이버캐스트에 큰 개편이 있었습니다. 기존에 등록하셨던 카테고리 번호가 모두 바뀌었습니다.<br/>
          이전에 구독하시던 주제를 계속 받아보실 수 있도록 하고 싶었으나 양이 너무 방대하고 새로운 주제와 1:1로 매칭되지도 않기에 마이그레이션은 포기하고 이렇게 공지로 대신합니다.<br/>
          새롭게 개편된 네이버캐스트 정보를 받아보고 싶다면, <a href="https://github.com/BenjaminKim/navercast_rss_feed">여기에</a> 방문하여 원하시는 주제를 다시 등록해주세요.<br/>
          <br/>
          좋은 소식이라면 구독할 수 있는 주제들이 더욱 다양해졌습니다. ^^
          </p>
        EOS
      end

      maker.channel.updated = updated_at
    end

    render xml: rss.to_xml
  end

  def index
    if params[:cid].to_i > 0 && params[:cid].to_i < 30000
      return migration_notice
    end

    cid = params[:cid] || 59088
    category_id = params[:category_id] || params[:categoryId]

    if category_id.blank?
      fail ArgumentError.new
    end

    items_data, feed_data = Rails.cache.fetch("cast_id/#{cid}", expires_in: CACHE_EXPIRING_TIME) do
      NavercastParser.fetch_data(cid, category_id)
    end
    rss = RSS::Maker.make('atom') do |maker|
      maker.channel.author = 'Benjamin'
      maker.channel.about = feed_data.about
      maker.channel.title = feed_data.title

      items_data.each do |x|
        maker.items.new_item do |item|
          item.link = x.link
          item.title = x.title
          item.updated = x.updated
          item.summary = x.summary
        end
      end

      maker.channel.updated = maker.items.max_by { |x| x&.updated.to_i }.updated
    end

    report_page_views(cid) rescue nil
    NavercastParser.report_google_analytics(cid, feed_data.title, request.user_agent)

    render xml: rss.to_xml
  end

  private
  def report_page_views(cid)
    key = "pv:#{Date.today}"
    REDIS_POOL.with do |conn|
      conn.hincrby(key, cid, 1)
    end
  end
end
