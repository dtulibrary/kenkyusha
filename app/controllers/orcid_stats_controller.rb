class OrcidStatsController < ApplicationController

  def index
    response.headers['Access-Control-Allow-Origin'] = '*'
    render :json => OrcidStat.where('extract(dow from created_at) = 1').order('created_at asc')
  end

end
