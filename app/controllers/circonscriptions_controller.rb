class CirconscriptionsController < ApplicationController

  def index
    @circonscriptions = ["Paris"]
    @circonscriptions += Panneau.all.group_by{|panneau| panneau.ville}.keys
    @circonscriptions.sort!
  end

end