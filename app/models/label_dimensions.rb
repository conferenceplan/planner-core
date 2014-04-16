class LabelDimensions < ActiveRecord::Base
  attr_accessible :name, :manufacturer, :page_size, :unit, :orientation, :across, :down, :label_width, :label_height,
                  :left_margin, :right_margin, :top_margin, :bottom_margin, :vertical_spacing, :horizontal_spacing

end
