require 'rss'
require 'navercast_parser'

class NaverCastController < ApplicationController
  CACHE_EXPIRING_TIME = Rails.env.production? ? 6.hours : 20.seconds

  def index
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
