module Arel
  module JSONPredications
    
    def key(key)
      Arel::Attributes::Key.new(self, key)
    end
    alias :[]     :key
    alias :index  :key
    
    def has_key(key)
      Arel::Nodes::HasKey.new(self, key)
    end
    
    def has_keys(*keys)
      Arel::Nodes::HasKeys.new(self, keys)
    end
    
    def has_any_key(*keys)
      Arel::Nodes::HasAnyKeys.new(self, keys)
    end
    
    def as(type)
      Arel::Attributes::Cast.new(self, type)
    end
    
  end
end