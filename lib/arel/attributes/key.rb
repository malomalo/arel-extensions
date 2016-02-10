module Arel
  module Attributes
    class Key < Attribute
      
      def able_to_type_cast?
        false
      end
      
      def table_name
        nil
      end
    end
  end
end