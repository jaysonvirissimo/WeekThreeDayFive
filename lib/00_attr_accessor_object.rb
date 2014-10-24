class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      setter = <<-SETTER
      def #{name}=(value)
        @#{name} = value
      end
      SETTER
      self.class_eval(setter)

      define_method(name) do
        instance_variable_get("@#{name}")
      end
    end
  end
end
