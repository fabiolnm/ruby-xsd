describe RubyXsd do
  describe "XMLSchema root validation" do
    it "rejects non-schema root" do
      ex = assert_raises RuntimeError do
        RubyXsd.models_from "<non-xs></non-xs>"
      end
      assert_equal "Invalid XMLSchema root", ex.message
    end

    it "rejects schema root without XMLSchema namespace" do
      ex = assert_raises RuntimeError do
        RubyXsd.models_from "<schema></schema>"
      end
      assert_equal "Missing XMLSchema namespace", ex.message
    end

    it "rejects schema with wrong XMLSchema namespace" do
      ex = assert_raises RuntimeError do
        RubyXsd.models_from "<xs:schema xmlns:xs='wrong'></xs:schema>"
      end
      assert_equal "Wrong XMLSchema namespace", ex.message
    end
  end

  let(:schema) {
    "<xs:schema xmlns:xs='#{RubyXsd::XMLSchemaNS}'>%s</xs:schema>"
  }

  describe "simple elements" do
    let(:template) {
      schema % "<xs:element name='%s' />"
    }

    it "defines object attributes" do
      RubyXsd.models_from template % [ "xsd_attr" ]
      RubyXsd.new.must_respond_to :xsd_attr
    end
  end
end
