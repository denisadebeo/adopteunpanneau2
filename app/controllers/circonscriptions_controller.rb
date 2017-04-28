class CirconscriptionsController < ApplicationController

  def index
    @circonscriptions = Panneau.all.group_by{|panneau| panneau.ville}.keys
  end

end