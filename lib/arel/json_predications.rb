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
      Arel::Nodes::HasAnyKey.new(self, keys)
    end
    
    def cast_as(type)
      Arel::Attributes::Cast.new(self, type)
    end
    
    def dig(*keys)
      keys = keys[0] if keys.size == 1 && keys.first.is_a?(Array)
      
      if keys.empty?
        self
      else
        keys.inject(self) { |node, key| Arel::Attributes::Key.new(node, key) }
      end
    end
    
  end
end