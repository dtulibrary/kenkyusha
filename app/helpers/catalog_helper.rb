module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def render_source_field_facet value
    t "source_labels.#{value}"
  end

  def render_source_field args
    args[:document]['source_ss'].collect {|s| t "source_labels.#{s}"}.join ' ; '
  end 

  def render_status_field_facet value
    t "status_labels.#{value}"
  end

  def render_status_field args
    ("<span style=\"color: ##{args[:document]['is_active_b'] ? '090' : '900'}\">%s</span>" % t("status_labels.#{args[:document]['is_active_b']}")).html_safe
  end

  def render_orcid_field_facet value
    t "orcid_labels.#{value}"
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

  def render_affiliation_show affiliation
    html = ''
    if affiliation['type'] == 'previous'
      from = affiliation['startDate'].gsub /(\d{4})(\d{2})(\d{2})/, '\1-\2-\3'
      to   = affiliation['endDate'].gsub /(\d{4})(\d{2})(\d{2})/, '\1-\2-\3'
      html += "<div style=\"color: #999\">#{from} to #{to}</div>"
    end
    affiliation['organisation']['names'].each do |name|
      if name['lang'] == 'eng'
        names = []
        (1..4).each {|i| names << name["level#{i}"]}
        html += "<div style=\"margin-bottom: 1em; margin-left: 2em; text-indent: -2em\">#{names.compact.join('<br>')}</div>"
      end
    end
    html.html_safe
  end

  def get_affiliations document
    (document['person_affiliations_ssf'] && JSON.parse(document['person_affiliations_ssf'].first) || [])
  end

  def get_current_affiliations document
    get_affiliations(document).select {|affiliation| affiliation['type'] == 'current'}
  end

  def get_previous_affiliations document
    get_affiliations(document).select {|affiliation| affiliation['type'] == 'previous'}
  end

  def has_current_affiliation? document
    get_affiliations(document).any? {|affiliation| affiliation['type'] == 'current'}
  end

  def has_previous_affiliation? document
    get_affiliations(document).any? {|affiliation| affiliation['type'] == 'previous'}
  end

  def has_researcher_image? document
    document['source_ss'].any? {|source| ['ps_dtu', 'ps_ku'].include? source} && document['cris_id_ssf']
  end

  def has_university_link? document
    document['source_ss'].any? {|source| ['ps_dtu'].include? source} && document['cris_id_ssf']
  end

  def render_university_links document
    html = ''
    cris_id = document['cris_id_ssf'].first
    document['source_ss'].each do |source|
      html += "<div><a target=\"_blank\" href=\"#{create_university_link source, cris_id}\">#{t "source_labels.#{source}"}</a></div>"
    end
    html.html_safe
  end

  def render_backlinks document
    html = ''
    uuid = document['member_id_ss'].first
    document['source_ss'].each do |source|
      html += "<div><a target=\"_blank\" href=\"#{create_backlink source, uuid}\">#{t "source_labels.#{source}"}</a></div>"
    end
    html.html_safe
  end

  def create_university_link source, cris_id
    {
      'ps_dtu' => 'http://www.dtu.dk/Service/Telefonbog/Person?id=%s&cpid=7531&tab=1'
    }[source] % cris_id
  end

  def create_backlink source, uuid
    {
      'ps_aau' => 'http://vbn.aau.dk/en/persons/id(%s).html',
      'ps_au'  => 'http://pure.au.dk/portal/en/persons/id(%s).html',
      'ps_cbs' => 'http://research.cbs.dk/portal/en/persons/id(%s)/publications.html',
      'ps_dtu' => 'http://orbit.dtu.dk/en/persons/id(%s).html',
      'ps_itu' => 'http://pure.itu.dk/portal/en/persons/id(%s).html',
      'ps_ku'  => 'http://forskning.ku.dk/search/?pure=en/persons/id(%s).html',
      'ps_ruc' => 'http://rucforsk.ruc.dk/site/en/persons/id(%s).html',
      'ps_sdu' => 'http://findresearcher.sdu.dk:8080/portal/en/persons/id(%s).html' 
    }[source] % uuid
  end
end
