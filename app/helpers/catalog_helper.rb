module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def render_source_field_facet value
    t "source_labels.#{value}"
  end

  def render_source_field args

    case t "source_labels.#{args[:document]['source_ss']}"
    when /["Orbit"]/
      'Technical University of Denmark'
    when /["Rdb Ku"]/
       'University of Copenhagen'
    when /["Rdb Itu"]/
       'IT University of Copenhagen'
    when /["Rdb Au"]/
       'Aarhus University'
    when /["Rdb Cbs"]/
       'Copenhagen Business School'
    when /["Rdb Ruc"]/
       'Roskilde University'
    when /["Rdb Sdu"]/
       'University of Southern Denmark'
    when /["Rdb Vbn"]/
       'Aalborg University'
    end 
  end
end
