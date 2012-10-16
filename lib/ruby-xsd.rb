require "ruby-xsd/version"
require "ruby-xsd/class_maker"
require "nokogiri"

class RubyXsd
  class << self
    include ClassMaker

    def models_from xsd_definitions
      doc = Nokogiri::XML xsd_definitions

      schema = doc.children.first
      raise "Invalid XMLSchema root" if schema.name != "schema"
      raise "Missing XMLSchema namespace" if schema.namespace.nil?
      raise "Wrong XMLSchema namespace" unless is_xml_schema_node schema

      schema.children.each { |node| make_definition node }
    end
  end
end
