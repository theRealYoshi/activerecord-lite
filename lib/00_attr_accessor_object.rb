
class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |name| #handle
      define_method(name) do
        self.instance_variable_get("@#{name}")
      end

      set_method = "#{name}="

      define_method(set_method) do |setter|
        self.instance_variable_set("@#{name}", "#{setter}")
      end

    end
  end

end
