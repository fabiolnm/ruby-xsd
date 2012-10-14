require "ruby-xsd/version"
require "active_support"
require "nokogiri"

class RubyXsd
  XMLSchemaNS = "http://www.w3.org/2001/XMLSchema"

  class << self
    include ActiveSupport::Inflector

    def models_from xsd_definitions
      doc = Nokogiri::XML xsd_definitions

      schema = doc.children.first
      raise "Invalid XMLSchema root" if schema.name != "schema"
      raise "Missing XMLSchema namespace" if schema.namespace.nil?
      raise "Wrong XMLSchema namespace" unless is_xml_schema_node schema

      schema.children.each { |node| make_definition node }
    end

    def make_definition node
      if is_element_node node
        attrs = node.attributes.to_hash
        name = attrs["name"].value
        type = attrs["type"].value if attrs.has_key? "type"
        if type.nil?
          define_class name
        else
          attr_accessor name
        end
      end
    end

    private
    def namespace_of node
      node.namespace.href
    end

    def is_xml_schema_node node
      namespace_of(node) == XMLSchemaNS
    end

    def is_element_node node
      is_xml_schema_node node and node.name == "element"
    end

    def define_class name
      name = classify name
      Object.const_set name, Class.new
    end
  end
end
