require "active_model"
require "active_support"

module ClassMaker
  include ActiveSupport::Inflector

  XMLSchemaNS = "http://www.w3.org/2001/XMLSchema"

  def make_definition node, target=Object
    return if is_text node

    attrs = node.attributes.to_hash
    name = attrs["name"].value
    if is_element node
      type = attrs["type"].value if attrs.has_key? "type"
      if type.nil?
        complex_node = select_children(node, "complexType").first
        define_class name, complex_node, target
      else
        attr_accessor name
      end
    elsif is_simple node
      if not name.nil?
        restrictions = select_children(node, "restriction").first
        define_validator name, restrictions, target
      end
    elsif is_complex_root node
      define_class name, node, target
    end
  end

  private
  def namespace_of node
    node.namespace.href
  end

  def is_text node
    node.name == "text"
  end

  def is_xml_schema_node node
    namespace_of(node) == XMLSchemaNS
  end

  def is_element node
    is_xml_schema_node node and node.name == "element"
  end

  def is_simple node
    is_xml_schema_node node and node.name == "simpleType"
  end

  def is_complex_root node
    is_xml_schema_node node and node.name == "complexType"
  end

  def define_class name, node, target
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
      elems.each { |e| make_definition e, self }
    end

    target.const_set name, cls
  end

  def define_validator name, restrictions, target
    name = classify "#{name}_validator"

    type = constantize classify restrictions
      .attributes["base"].value.split(":").last

    ws_action = select_children(restrictions, "whiteSpace").first
    ws_action = ws_action.attributes["value"].value unless ws_action.nil?

    enum_values = select_children(restrictions, "enumeration").collect { |enum|
      enum.attributes["value"].value
    }

    pattern = select_children(restrictions, "pattern").first
    pattern = pattern.attributes["value"].value unless pattern.nil?

    cls = Class.new ActiveModel::EachValidator do
      const_set "TYPE", type
      const_set("WS_ACTION", ws_action) unless ws_action.nil?
      const_set "ENUM_VALUES", enum_values
      unless pattern.nil?
        const_set "PATTERN", pattern
        const_set "REGEXP", Regexp.new("^#{pattern}$")
      end

      def validate_each record, attribute, value
        validate_type record, attribute, value
        handle_whitespaces record, attribute, value
        validate_enumeration record, attribute, value unless self.class::ENUM_VALUES.empty?
        validate_regexp record, attribute, value if self.class.const_defined? "REGEXP"
      end

      private
      def validate_type record, attribute, value
        unless value.kind_of? self.class::TYPE
          add_error record, attribute, "#{value}: not a #{self.class::TYPE}"
        end
      end

      def handle_whitespaces record, attribute, value
        if self.class.const_defined? "WS_ACTION"
          case self.class::WS_ACTION
          when "replace" then value.gsub! /[\n\t\r ]/, " "
          when "collapse" then
            value.gsub! /[\n\t\r]/, " "
            value = value.split.join " "
          end
          record.send "#{attribute}=", value
        end
      end

      def validate_enumeration record, attribute, value
        unless self.class::ENUM_VALUES.include? value.to_s
          add_error record, attribute, "#{value}: not in #{self.class::ENUM_VALUES}"
        end
      end

      def validate_regexp record, attribute, value
        unless value =~ self.class::REGEXP
          add_error record, attribute, "#{value}: not matching #{self.class::PATTERN}"
        end
      end

      def add_error record, attribute, message=""
        record.errors[attribute] << (options[:message] || message)
      end
    end
    target.const_set name, cls
  end

  def select_children node, name
    node.children.select { |n| n.name == name }
  end
end
