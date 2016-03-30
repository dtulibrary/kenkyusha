class OrcidStatsController < ApplicationController

  def index
    response.headers['Access-Control-Allow-Origin'] = '*'
    stat_dates = []
    stat_dates << {:dow => 1}
    stat_dates << {:year => 2016, :month => 3, :day => 31}
    stat_dates_clause = stat_dates.map {|date| "(#{stat_date_clause(date)})"}
                                  .join(" OR ")
    render :json => OrcidStat.where(stat_dates_clause)
                             .order('created_at asc')
  end

  private
    def stat_date_clause(date)
      [:year, :month, :day, :dow].reject {|part| date[part].nil?}
                                 .map {|part| "extract(#{part} from created_at) = #{date[part]}"}
                                 .join(' AND ')
    end
end
