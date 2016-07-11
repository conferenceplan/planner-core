kai = "#{Rails.root}/public/gkai00mp.ttf"

def planner_fallback_fonts
  ["Open Sans", 'kai']
end

pdf.font_families.update("times" => {
    :normal => "Times-Roman",
    :italic      => "Times-Italic",
    :bold        => "Times-Bold",
    :bold_italic => "Times-BoldItalic"
  })

pdf.font_families.update(
      "kai" => {
        :normal => { :file => kai, :font => "Kai" },
        :bold   => kai,
        :italic => kai,
        :bold_italic => kai
       }
    )

pdf.font_families.update(
      "Open Sans" => {
        :normal => { :file => "#{Rails.root}/public/OpenSans-Regular.ttf", :font => "OpenSans-Regular" },
        :italic => { :file => "#{Rails.root}/public/OpenSans-Italic.ttf", :font => "OpenSans-Italic" },
        :bold   => { :file => "#{Rails.root}/public/OpenSans-Bold.ttf", :font => "OpenSans-Bold" },
        :bold_italic => { :file => "#{Rails.root}/public/OpenSans-BoldItalic.ttf", :font => "OpenSans-BoldItalic" },
       }
    )

pdf.font "Open Sans"
