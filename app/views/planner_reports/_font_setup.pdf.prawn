kai = "#{Rails.root}/public/gkai00mp.ttf"
dejavu = "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

def fallback_fonts
  ["times", 'kai']
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
