module Arel
  module Attributes
    class Key < Attribute
      
      def able_to_type_cast?
        false
      end
      
      def table_name
        nil
      end
      
      def type_cast_for_database(value)
        relation.type_cast_for_database(value)
      end
      
    end
  end
end