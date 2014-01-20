class CreateLabelDimensions < ActiveRecord::Migration
  def change
    create_table :label_dimensions do |t|
      t.string :name
      t.string :manufacturer
      t.string :page_size
      t.string :unit
      t.string :orientation
      t.integer :across
      t.integer :down
      t.float :label_width
      t.float :label_height
      t.float :left_margin
      t.float :right_margin
      t.float :top_margin
      t.float :bottom_margin
      t.float :vertical_spacing
      t.float :horizontal_spacing

      t.timestamps
    end
  end
end


#
# Get PDF sizes from Prawn::Document::PageGeometry::SIZES
#
