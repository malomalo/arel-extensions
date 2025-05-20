# frozen_string_literal: true

module Arel
  module Attributes
    class Relation < Attribute
      
      attr_accessor :collection, :for_write
      
      def initialize(relation, name, collection = false, for_write=false)
        self[:relation] = relation
        self[:name] = name
        @collection = collection
        @for_write = for_write
      end
      
      def able_to_type_cast?
        relation.able_to_type_cast?
      end
      
      def table_name
        nil
      end
      
      def eql? other
        self.class == other.class &&
          self.relation == other.relation &&
          self.name == other.name &&
          self.collection == other.collection
      end

      def type_cast_for_database(value)
        relation.type_cast_for_database(value)
      end

    end
  end
end