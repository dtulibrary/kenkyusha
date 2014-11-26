class OrcidStatsController < ApplicationController

  def index
    render :json => OrcidStat.all
  end

end
