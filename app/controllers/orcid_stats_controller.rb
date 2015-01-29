class OrcidStatsController < ApplicationController

  def index
    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json => OrcidStat.all
  end

end
