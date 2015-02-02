class OrcidStatsController < ApplicationController

  def index
    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json => OrcidStat.order('created_at asc')
  end

end
