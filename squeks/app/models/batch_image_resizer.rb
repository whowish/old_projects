class BatchImageResizer

  def initialize()
  end

  def perform
    FigureImage.all.each { |obj|
      Delayed::Job.enqueue ImageResizer.new(obj.original_image_path)
    }

  end
end