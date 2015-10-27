require 'httparty'

HTTP_TIMEOUT = 60*60
BATCH_SIZE   = 20

namespace :orcid_stats do
  desc 'Update ORCID statistics'
  task :update => :environment do
    #solr = Blacklight.solr
    #response = solr.get 'ddf_pers', :params => solr_params
    # Make hash from array
    #facets = Hash[*response['facet_counts']['facet_fields']['source_ss']]
    # Rename hash keys
    #facets = Hash[facets.collect {|k,v| [k.sub('ps_', ''), v]}]
    #OrcidStat.create facets
  end

  desc 'Fetch Pure records'
  task :fetch => :environment do
    fetcher_contexts = {}
    source_urls.each do |name, url|
      fetcher_contexts[name] = {
        :offset => 0,
        :counters => {
          :total         => fetch_person_count(url).to_i,
          :persons       => 0,
          :total_orcid   => 0,
          :current_orcid => 0
        }
      }
    end

    puts "Records to be fetched (in batches of #{BATCH_SIZE}):"
    fetcher_contexts.each do |name, ctx|
      puts "#{name}: #{ctx[:counters][:total]}"
    end

    counter = 0

    while fetcher_contexts.any? {|_, ctx| ctx[:offset] < ctx[:counters][:total]}
      fetcher_contexts.select {|_, ctx| ctx[:offset] < ctx[:counters][:total]}.each do |name, ctx|
        url   = "#{source_urls[name]}&offset=#{ctx[:offset]}"
        batch = fetch_person_batch(url)

        ctx[:offset] += batch[:size]
        ctx[:counters][:persons] += batch[:size]
        ctx[:counters][:total_orcid] += batch[:total_orcid]
        ctx[:counters][:current_orcid] += batch[:current_orcid]

        counter += batch[:size]

        print '.'
        print " " if counter % 1000 == 0
        print "#{counter}\n" if counter % 2000 == 0
      end
    end

    puts "\nDone!"

    fetcher_contexts.each do |name, ctx|
      puts "Results for #{name}: #{ctx}"
    end
  end
end

def fetch_person_batch(url)
  batch = {
    :size          => 0,
    :total_orcid   => 0,
    :current_orcid => 0
  }

  url = "#{url}&window.size=#{BATCH_SIZE}"

  response = HTTParty.get url, :timeout => HTTP_TIMEOUT
  if response.code == 200
    persons_handled = 0
    each_person(response.body) do |person|
      has_orcid         = orcid?(person)
      has_current_assoc = false

      each_staff_org_assoc(person) do |assoc|
        has_current_assoc = has_current_assoc || current_assoc?(assoc)
      end

      batch[:size]          += 1
      batch[:total_orcid]   += 1 if has_orcid
      batch[:current_orcid] += 1 if has_orcid && has_current_assoc
      persons_handled += 1
    end
    if persons_handled == 0
      puts "No persons handled for #{url}"
    end
  else
    Rails.logger.error "Error fetching from #{url}"
    raise 'Error fetching person batch'
  end

  batch
rescue e
  puts "Exception while fetching person batch: #{e.message}"
end

def orcid?(xml)
  xml.match(/<cur:orcid>.+?<\/cur:orcid>/)
end

def current_assoc?(xml)
  has_current_assoc = false
  xml.scan(/<cur:period>(.*?)<\/cur:period>/m) do |content,_|
    has_current_assoc = has_current_assoc || !content.match(/<extensions-core:endDate>.+?<\/extensions-core:endDate>/)
  end
  has_current_assoc
end

def each_staff_org_assoc(xml)
  xml.scan(/<cur:staffOrganisationAssociation .*?>(.+?)<\/cur:staffOrganisationAssociation>/m) do |content,_|
    yield content
  end
end

def each_person(xml)
  xml.scan(/<core:content .*?>(.*?)<\/core:content>/m) do |content,_| 
    yield content
  end
end

def fetch_person_count(url)
  url = "#{url}&window.size=0"
  puts "Fetching count for #{url}"
  response = HTTParty.get url, :timeout => HTTP_TIMEOUT
  if response.code == 200
    response.body.match(/<core:count>(\d*?)<\/core:count>/)[1]
  else
    Rails.logger.error "Error fetching from #{url}"
    raise 'Error getting person count'
  end
end

def source_urls
  {
    :aau     => 'http://vbn.aau.dk/ws/rest/person.current?rendering=xml_long',#&uuids.uuid=dd353d6c-aa8b-4db0-9569-b65411935ccc',
#    :ark     => 'http://research.kadk.dk/ws/rest/person.current?rendering=xml_long',
#    :au      => 'http://pure.au.dk/ws/rest/person.current?rendering=xml_long',
#    :cbs     => 'http://research.cbs.dk/ws/rest/person.current?rendering=xml_long',
#    :fak     => 'http://pure.fak.dk/ws/rest/person.current?rendering=xml_long',
#    :itu     => 'https://pure.itu.dk/ws/rest/person.current?rendering=xml_long',
#    :ka      => 'http://pure-01.kb.dk/ws/rest/person.current?rendering=xml_long',
#    :ku      => 'http://curis.ku.dk/ws/rest/person.current?rendering=xml_long',
#    :orbit   => 'http://orbit.dtu.dk/ws/rest/person.current?rendering=xml_long',#&uuids.uuid=7cd29964-212e-4343-8cb4-c9729ef733e9',
#    :ruc     => 'http://rucforsk.ruc.dk/ws/rest/person.current?rendering=xml_long',
#    :sbi     => 'http://forskning.regionh.dk/ws/rest/person.current?rendering=xml_long',
#    :sdu     => 'http://findresearcher.sdu.dk/ws/rest/person.current?rendering=xml_long',
#    :ucviden => 'https://www.ucviden.dk/ws/rest/person.current?rendering=xml_long',
  }
end

def solr_params
  {   
    'q'           => 'has_orcid_b:1', 
    'facet'       => 'true', 
    'facet.field' => 'source_ss', 
    'rows'        => 0 
  }   
end 
