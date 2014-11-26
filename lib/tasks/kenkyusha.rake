namespace :orcid_stats do
  desc 'Update ORCID statistics'
  task :update => :environment do
    solr = Blacklight.solr
    response = solr.get 'ddf_pers', :params => solr_params
    # Make hash from array
    facets = Hash[*response['facet_counts']['facet_fields']['source_ss']]
    # Rename hash keys
    facets = Hash[facets.collect {|k,v| [k.sub('ps_', ''), v]}]
    OrcidStat.create facets
  end
end

def solr_params
  {   
    'q'           => 'has_orcid_b:1', 
    'facet'       => 'true', 
    'facet.field' => 'source_ss', 
    'rows'        => 0 
  }   
end 
