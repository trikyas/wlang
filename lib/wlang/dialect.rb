require 'wlang/dialect/dispatching'
require 'wlang/dialect/dsl'
module WLang
  class Dialect
    include Dialect::Dispatching
    include Dialect::DSL
    
    attr_reader :braces
    
    def initialize(braces = WLang::BRACES)
      @braces = braces
    end
    
    def self.parse(source, braces = WLang::BRACES)
      new(braces).send(:parse, source)
    end
    
    def self.compile(source, braces = WLang::BRACES)
      new(braces).send(:compile, source)
    end
    
    def self.template(source, braces = WLang::BRACES)
      new(braces).send(:template, source)
    end
    
    def self.instantiate(tpl, scope = {}, braces = WLang::BRACES)
      new(braces).send(:instantiate, tpl, scope)
    end
    
    private
    
    def parse(source)
      source = File.read(source.to_path) if source.respond_to?(:to_path)
      source = source.to_str if source.respond_to?(:to_str)
      WLang::Parser.new.call(source)
    end
    
    def compile(source)
      compiler.call(parse(source))
    end
    
    def template(source)
      compiled = eval(compile(source), TOPLEVEL_BINDING)
      lambda do |scope|
        with_scope(scope) do
          compiled.call(self, "")
        end
      end
    end
    
    def instantiate(source, scope)
      template(source).call(scope)
    end
    
    def compiler
      Class.new(Temple::Engine) do
        use WLang::Compiler, :dialect => self
        use WLang::Generator
      end.new
    end
    
  end # class Dialect
end # module WLang