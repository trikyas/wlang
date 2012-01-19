require 'wlang/dialect/dispatching'
require 'wlang/dialect/dsl'
module WLang
  class Dialect
    include Dialect::Dispatching
    include Dialect::DSL
    
    DEFAULT_OPTIONS = {
      :braces => WLang::BRACES,
    }
    
    def initialize(options = {})
      @options  = DEFAULT_OPTIONS.merge(options)
      @compiler = WLang::Compiler.new(self)
    end
    
    def self.parse(source, options = {})
      new(options).send(:parse, source)
    end
    
    def self.compile(source, options = {})
      new(options).send(:compile, source)
    end
    
    def self.render(source, scope = {}, buffer = "")
      compile(source).call(scope, buffer)
    end
    
    private
    
    attr_reader :options
    
    def braces
      options[:braces]
    end
    
    def parse(source)
      @compiler.parse(source)
    end
    
    def compile(source)
      @compiler.compile(source)
    end
    
    
  end # class Dialect
end # module WLang
