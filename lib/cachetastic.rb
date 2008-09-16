# :include: README
require 'rubygems'
require 'singleton'
require 'logger'
require 'yaml'
require 'zlib'
require 'pp'
require 'drb'
require 'configatron'
begin
  require 'memcache'
rescue Exception => e
  # if you don't have memcache installed, don't 
  # blow up, print a message, and you can't use
  # the memcache adapter.
  puts "CACHETASTIC: Warning: You don't have the memcache gem installed which means you can't use the Cachetastic::Adapters::Memcache adapter."
end

class Object
  # Uses <code>define_method</code> to create an empty for the method parameter defined.
  # That method will then raise MethodNotImplemented. This is useful for creating interfaces
  # and you want to stub out methods that others need to implement.
  def self.needs_method(meth)
    define_method(meth) do
      raise NoMethodError.new("The interface you are using requires you define the following method '#{meth}'")
    end
  end
end

module Cachetastic #:nodoc:#
  module Caches #:nodoc:#
  end
  module Adapters #:nodoc:#
  end
  module Errors #:nodoc:#
  end
  module Cacheable
  end
end
module ActiveRecord #:nodoc:#
end

home = File.dirname(__FILE__)

require File.join(home, 'cachetastic_connection')
require File.join(home, 'cachetastic_logger')
require File.join(home, 'caches/cachetastic_caches_base')
require File.join(home, 'caches/cachetastic_caches_page_cache')
require File.join(home, 'caches/cachetastic_caches_rails_session_cache')
require File.join(home, 'caches/cachetastic_caches_mack_session_cache')
require File.join(home, 'errors/cachetastic_errors_unsupported_adapter')
require File.join(home, 'adapters/cachetastic_adapters_base')
require File.join(home, 'adapters/cachetastic_adapters_store_object')
require File.join(home, 'adapters/cachetastic_adapters_memcache')
require File.join(home, 'adapters/cachetastic_adapters_local_memory')
require File.join(home, 'adapters/cachetastic_adapters_file_base')
require File.join(home, 'adapters/cachetastic_adapters_file')
require File.join(home, 'adapters/cachetastic_adapters_html_file')
require File.join(home, 'adapters/cachetastic_adapters_drb')
require File.join(home, 'cachetastic_cacheable')
require File.join(home, 'rails_extensions/cachetastic_active_record_base')
require File.join(home, 'rails_extensions/cgi_session_cachetastic_store')

# unless configatron.exists?(:cachetastic_default_options)
#   configatron do |config|
#     config.namespace(:cachetastic_default_options) do |c|
#       c.debug = false
#       c.adapter = :local_memory
#       c.logger = ::Logger.new(STDOUT)
#     end
#   end
# end
config = {
  :cachetastic_default_options => {
    :debug => false,
    :adapter => :local_memory,
    :logger => ::Logger.new(STDOUT)
  }
}
configatron.configure_from_hash(config.recursive_merge(configatron.to_hash))

#--
# http://rdoc.sourceforge.net/doc/index.html
#++