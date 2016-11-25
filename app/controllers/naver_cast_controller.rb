require 'naver_cast_parser'
require 'rss'

class NaverCastController < ApplicationController
  CACHE_EXPIRING_TIME = Rails.env.production? ? 6.hours : 20.seconds

  def index
    cid = params[:cid] || 122

    items_data, feed_data = Rails.cache.fetch("cast_id/#{cid}", expires_in: CACHE_EXPIRING_TIME) do
      fetch_data(cid)
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

      maker.channel.updated = maker.items.max_by {|x| x.updated}.updated
    end

    report_page_views(cid)
    report_google_analytics(cid, feed_data.title)

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
