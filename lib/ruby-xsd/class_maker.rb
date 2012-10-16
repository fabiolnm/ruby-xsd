require "active_support"

module ClassMaker
  include ActiveSupport::Inflector

  XMLSchemaNS = "http://www.w3.org/2001/XMLSchema"

  def make_definition node
    attrs = node.attributes.to_hash
    name = attrs["name"].value
    if is_element node
      type = attrs["type"].value if attrs.has_key? "type"
      if type.nil?
        complex_node = select_children(node, "complexType").first
        define_class name, complex_node
      else
        attr_accessor name
      end
    elsif is_complex_root node
      define_class name, node
    end
  end

  private
  def namespace_of node
    node.namespace.href
  end

  def is_xml_schema_node node
    namespace_of(node) == XMLSchemaNS
  end

  def is_element node
    is_xml_schema_node node and node.name == "element"
  end

  def is_complex_root node
    is_xml_schema_node node and node.name == "complexType"
  end

  def define_class name, node
    name = classify name

    elems = []
    unless node.nil?
      sequence = select_children node, "sequence"
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
