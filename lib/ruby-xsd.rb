require "ruby-xsd/version"
require "nokogiri"

class RubyXsd
  XMLSchemaNS = "http://www.w3.org/2001/XMLSchema"

  def self.models_from xsd_definitions
    doc = Nokogiri::XML xsd_definitions

    schema = doc.children.first
    raise "Invalid XMLSchema root" if schema.name != "schema"
    raise "Missing XMLSchema namespace" if schema.namespace.nil?
    raise "Wrong XMLSchema namespace" unless is_xml_schema_node schema

    schema.children.each { |node| make_definition node }
  end

  def self.make_definition node
    if is_element_node node
      attrs = node.attributes.to_hash
      define_accessor attrs["name"]
    end
  end

  private
  def self.namespace_of node
    node.namespace.href
  end

  def self.is_xml_schema_node node
    namespace_of(node) == XMLSchemaNS
  end

  def self.is_element_node node
    is_xml_schema_node node and node.name == "element"
  end

  def self.define_accessor name
    define_method name do
      instance_variable_get "@#{name}"
    end

    define_method "#{name}=" do |value|
      instance_variable_set "@#{name}", value
    end
  end
end
