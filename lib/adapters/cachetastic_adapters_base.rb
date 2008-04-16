# This class is the interface used to develop adapters for stores.
# Stores are where the data is actually held. These could be local memory,
# memcached, a database, the file system, etc...
# If you implement this API, then you should be able to plug in different
# stores for your caches without having to change any of your code.
# 
# === Methods that need to be implemented:
# * setup - used to setup the implementation of the adapter.
# * set(key, object, expiry) - sets an object into the store using the given key and the expiry time.
# * get(key) - returns an object from the store for a given key.
# * delete(key, delay) - deletes an object from the store for a given key. If the store supports it, a delay can be used.
# * expire_all - expires all objects in the store for a given cache.
# * stats - returns statistics for the store.
# * valid? - used to test whether or not the store is still valid. If this returns false a new instance of the adapter is created by Cachetastic::Connection
class Cachetastic::Adapters::Base
  
  attr_reader :all_options
  attr_reader :store_options
  attr_reader :servers
  attr_reader :name
  attr_reader :logging
  attr_reader :logger
  
  def initialize(name)
    @name = name
    configure
    setup
    if self.debug?
      self.logger.debug(self.name, :self, self.inspect)
      self.logger.debug(self.name, :options, self.all_options.inspect)
    end
  end
  
  # foo bar
  [:setup, :set, :get, :delete, :expire_all, :stats, "valid?"].each do |meth|
    define_method(meth) do |*args|
      raise MethodNotImplemented.new(meth)
    end
  end
  
  # Returns true/or falsed based on whether or not the debug setting is set to true in the
  # configuration file. If the config setting is set, then false is returned.
  def debug?
    ivar_cache(:debug) do
      (self.all_options["debug"] == true || false)
    end
  end
  
  def stats
    cache_name = self.name.to_s.camelize
    adapter_type = self.class.to_s.gsub('Cachetastic::Adapters::', '')
    s = "Cache: #{cache_name}\nStore Type: #{adapter_type}\n"
    if self.servers
      servers = self.servers.join(',')
      s += "Servers: #{servers}"
    end
    puts s
  end
  
  class << self
    # Merges options for the store in the configuration file with the cachetastic_default_options 
    # found in the configuration file, and returns the results.
    # Options need to be specified in the configuration file as the methodized name of the cache with
    # _options attached at the end.
    # Examples:
    #   Cachetastic::Caches::PageCache # => cachetastic_caches_page_cache_options
    #   MyAwesomeCache # => my_awesome_cache_options
    def get_options(name)
      options = (app_config.cachetastic_default_options || {})
      options = {"adapter" => "local_memory"}.merge(options)
      options = options.merge(app_config.send(name.methodize + "_options") || {})
      options
    end
  end
  
  private
  def configure
    @all_options = Cachetastic::Adapters::Base.get_options(self.name)
    @store_options = (self.all_options["store_options"] || {})
    @servers = self.all_options["servers"]
    @logging = (self.all_options["logging"] || {})
    @logger = Cachetastic::Logger.new(self.logging, self.name)
  end
  
end