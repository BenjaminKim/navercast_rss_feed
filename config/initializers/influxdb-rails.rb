InfluxDB::Rails.configure do |config|
  config.influxdb_database = "navercast_#{Rails.env}"
  config.influxdb_hosts    = ["localhost"]
  config.influxdb_port     = 8086

  config.series_name_for_controller_runtimes = "rails.controller"
  config.series_name_for_view_runtimes       = "rails.view"
  config.series_name_for_db_runtimes         = "rails.db"
end
