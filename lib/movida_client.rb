require 'resourceful'
require 'nokogiri'

module MovidaClient
  
  class DigestAuth < Resourceful::DigestAuthenticator
  end
  
  class Resource
    def initialize(auth, xml)
      @auth = auth
      @xml = xml
    end
    
    private
    
    def method_missing(meth, *args, &blk)
      attribute = @xml.at_xpath("./*[name()='#{meth}']")
      return node_text(attribute) if attribute
      
      link = @xml.at_xpath("./link[@rel='#{meth}']")
      return get_linked_resource(link) if link
      
      super
    end
    
    def get_linked_resource(link)
      expansion = link.at_xpath("./*")
      expansion ? MovidaClient.instantiate(expansion, @auth) : MovidaClient::Resource(link['href'], @auth)
    end
    
    def node_text(node)
      case node['type']
      when "integer": node.text.to_i
      when "datetime": Time.parse(node.text)
      else
        node.text
      end
    end
  end
  
  def self.Resource(url, auth, params = {})
    http = Resourceful::HttpAccessor.new(:authenticator => auth)
    response = http.resource(add_params(url, params)).get
    instantiate Nokogiri.parse(response.body).root, auth
  end
  
  def self.instantiate(node, auth)
    if node['type'] == 'array'
      node.xpath("./*").map { |subnode| Resource.new(auth, subnode) }
    else
      Resource.new(auth, node)
    end
  end
  
  def self.add_params(url, options)
    options[:expand] = options[:expand].join(",") if options[:expand].is_a?(Array)
    params = options.map { |k, v| "#{k}=#{v}" }.join("&")
    params = "?#{params}" unless params.empty?
    url + params
  end
  
  def self.ResourceCollection(*args)
    ResourceCollection.new(*args)
  end
  
end