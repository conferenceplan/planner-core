class MenusController < ApplicationController
  def index
    # TODO: change to find by name with name of main
    @menu = Menu.find_by_title("Main")
  end

  def show
    @menu = Menu.find(params[:id])
  end
end
