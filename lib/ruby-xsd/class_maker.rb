require "active_support"

module ClassMaker
  include ActiveSupport::Inflector

  XMLSchemaNS = "http://www.w3.org/2001/XMLSchema"

  def make_definition node
    if is_element_node node
      attrs = node.attributes.to_hash
      name = attrs["name"].value
      type = attrs["type"].value if attrs.has_key? "type"
      if type.nil?
        define_class name, node
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

  def define_class name, node
    name = classify name

    elems = []
    complex_type = select_children node, "complexType"
    unless complex_type.empty?
      sequence = select_children complex_type.first, "sequence"
      elems = select_children sequence.first, "element" unless sequence.empty?
    end

    cls = Class.new do
      class << self
        include ClassMaker
      end
      elems.each { |e| make_definition e }
    end

    Object.const_set name, cls
  end

  def select_children node, name
    node.children.select { |n| n.name == name }
  end
end
