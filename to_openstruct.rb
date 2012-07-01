class Hash
  def to_openstruct
    mapped = {}
    each{ |key,value| mapped[key] = value && value.to_openstruct || value }
    OpenStruct.new(mapped)
   end
end

class Array
  def to_openstruct
    map{ |el| el.to_openstruct }
  end
end

class Object
  def to_openstruct
    self
  end
end