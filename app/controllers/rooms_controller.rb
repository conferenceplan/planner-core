class RoomsController < ApplicationController
  before_filter :require_user

  def index
    @rooms = Room.find :all
  end
  def show
    @room = Room.find(params[:id])
  end
  def create
    @room = Room.new(params[:room])
    if (@room.save)
       redirect_to :action => 'show', :id => @room
    else
      render :action => 'new'
    end 
  end
  def new
    @room = Room.new
  end
  
  def edit
    @room = Room.find(params[:id])
  end
  
  def update
    @room = Room.find(params[:id])
    if @room.update_attributes(params[:room])
      redirect_to :action => 'show', :id => @room
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    redirect_to :action => 'index'
  end
  
end
