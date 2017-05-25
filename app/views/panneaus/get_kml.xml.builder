xml.instruct!

xml.Document {

  xml.tag!("Style",{"id"=>"mavoix-ok"}) {
    xml.tag!("IconStyle"){
      xml.tag!("Icon") {
        xml.tag!("href"){xml.text!("http://#{request.host}/mavoix-ok.png")}
      }
    }
  }
  xml.tag!("Style",{"id"=>"mavoix-no"}) {
    xml.tag!("IconStyle"){
      xml.tag!("Icon") {
        xml.tag!("href"){xml.text!("http://#{request.host}/mavoix-no.png")}
      }
    }
  }
  @panneaus.each{|panneau|
    if panneau.is_ok
      icon_style = "mavoix-ok"
    else
      icon_style = "mavoix-ok"
    end
    xml.Placemark{
      xml.tag!("description") {xml.text!(panneau.name)}
      xml.tag!("Point") {
        xml.tag!("coordinates") {xml.text!("#{panneau.lat},#{panneau.long}")}
      }
      xml.tag!("styleUrl") {xml.text(icon_style)}
    }
  }
}