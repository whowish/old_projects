class ImageResizerController < ApplicationController
  
  def index
    Delayed::Job.enqueue BgImageResizer.new
  end
  
end
