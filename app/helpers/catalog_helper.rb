module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def render_source_field_facet value
    t "source_labels.#{value}"
  end

  def render_source_field args
    args[:document]['source_ss'].collect {|s| t "source_labels.#{s}"}.join ' ; '
  end 

  def create_researcher_image_url document
    t "image_urls.#{document['source_ss'].first}", :default => nil, :id => document['cris_id_ssf'].first if document['cris_id_ssf']
  end

  def render_person_affiliations_index document
    affiliations = []
    json = JSON.parse document['person_affiliations_ssf'].first
    json.each do |affiliation|
      if affiliation['type'] == 'current'
        affiliation['organisation']['names'].each do |name|
          if name['lang'] == 'eng'
            names = []
            (1..4).each {|i| names << name["level#{i}"]}
            affiliations << names.compact.join(' &mdash; ')
          end
        end
      end
    end
    affiliations.join('<br>').html_safe
  end

  def render_person_affiliations_show document
  end

  def has_active_affiliation? document
    document['person_affiliations_ssf'] && JSON.parse(document['person_affiliations_ssf'].first).any? {|affiliation| affiliation['type'] == 'current'}
  end

  def has_researcher_image? document
    document['source_ss'].any? {|source| ['ps_dtu'].include? source} && document['cris_id_ssf']
  end
end
