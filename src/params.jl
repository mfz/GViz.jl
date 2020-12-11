export px, inch, mm, cm, defaultparams

# useful units

const px = 1
const inch = 72
const mm = inch/25.4
const cm = 10mm

# graphical default parameters

"Graphical default parameters for GViz"
defaultparams = Dict(:margin_top => 2mm,              # margin between data view and frame
                     :margin_bottom => 2mm,
                     :margin_left => 20mm,
                     :margin_right => 10mm,
                     
                     :title_font => "SansSerif bold 8",
                     :title_color => "grey",
                     
                     :axis_font => "SansSerif bold 6",
                     :axis_color => "grey",
                     :axis_line_width => 1,
                     :axis_tick_length => 5,
                     
                     :base_line_y => 0.0,
                     :base_line_color => "lightgrey",
                     :base_line_width => 1,

                     # DataTrack layers
                     :shape => "circle",
                     :size => 2,
                     :border => 0.1, 
                     :color => "black",
                     :fill => "red",
                     :alpha => 0.5,

                     # GenomicFeatureTrack
                     :feature_height => 6mm,
                     :feature_fill => "lightblue",
                     :feature_label_font => "Sansserif 6",
                     :feature_label_color => "grey",
                     :feature_label_spacing => 1mm,
                     
                     :width => 20cm,
                     :height => 3cm)

