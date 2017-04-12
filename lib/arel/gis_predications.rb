module Arel
  module GISPredications
    
    def within(n=nil, e=nil, s=nil, w=nil)
      if n.class.to_s == 'String' && e.nil?
        within(*n.split(','))
      elsif n.is_a?(Array)
        within(*n)
      elsif n.is_a?(Hash)
        if (n.keys - [:n, :e, :s, :w]).empty?
          within(n[:n], n[:e], n[:s], n[:w])
        elsif (n.keys - [:north, :east, :south, :west]).empty?
          within(n[:north], n[:east], n[:south], n[:west])
        else
          radius = n[:radius] * 1609.34
          point_args = [point[:longitude], point[:latitude], radius].map { |x| Arel::Nodes.build_quoted(x) }
          point = Arel::Nodes::NamedFunction.new('ST_MakePoint', point_args).cast_as('geography')
          Arel::Nodes::NamedFunction.new('ST_DWithin', [self, point, radius])
        end
      else
        make_envelope_args = [w, s, e, n, 4326].map { |x| Arel::Nodes.build_quoted(x) }
        envelope = Arel::Nodes::NamedFunction.new('ST_MakeEnvelope', make_envelope_args)
        # Arel::Nodes::NamedFunction.new('ST_Contains', [envelope, self])
        Arel::Nodes::NamedFunction.new('ST_Within', [self, envelope])
      end
    end

  end
end