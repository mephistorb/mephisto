class MacroFilter < AbstractFilter
  @@macros = {}
  cattr_accessor :macros
  
  #TODO: Backreferences
  @@patterns = [
    /<filter:([_a-zA-Z0-9]+)[^>]*\/>/,
    /<filter:([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/filter:([_a-zA-Z0-9]+)>/m
    ]
  cattr_accessor :patterns
    
  def self.filter(text, options = {})
    macro_classes = self.macro_classes
    macro_classes.stringify_keys!
    @@patterns.each do |pattern|
    text.gsub!(pattern) do |match|
        macro_classes[$1].filter(self.hash_from_attributes(match)) if macro_classes.keys.include?($1)
      end
    end
    text
  end
  
  protected
  
  def self.hash_from_attributes(string)
    attributes = Hash.new

    string.gsub(/([^ =]+="[^"]*")/) do |match|
      key,value = match.split(/=/,2)
      attributes[key] = value.gsub(/"/,'')
    end

    attributes.symbolize_keys!
  end
  
  def self.macro_classes
    returning macros = {} do 
      Dir[File.dirname(__FILE__) + "/macros/*_macro.rb"].each do |macro|
        load(macro)
        macro_file = File.basename(macro).sub(/_macro\.rb/, '')
        macros[macro_file.to_sym] = "#{macro_file}_macro".camelize.constantize
      end
    end
  end
  
end