module Arel
  module GISPredications
    
    def within(n=nil, e=nil, s=nil, w=nil)
      if n.class.to_s == 'String' && e.nil?
        within(*n.split(','))
      elsif n.is_a?(Array)
        within(*n)
      elsif n.is_a?(Hash)
        n = n.symbolize_keys
        if (n.keys - [:n, :e, :s, :w]).empty?
          within(n[:n], n[:e], n[:s], n[:w])
        elsif (n.keys - [:north, :east, :south, :west]).empty?
          within(n[:north], n[:east], n[:south], n[:west])
        elsif (n.keys - [:radius, :r, :latitude, :lat, :longitude, :lng, :lon]).empty?
          n[:radius] = n[:r] if !n.has_key?(:radius) && n.has_key?(:r)
          n[:latitude] = n[:lat] if !n.has_key?(:latitude) && n.has_key?(:lat)
          n[:longitude] = n[:lng] if !n.has_key?(:longitude) && n.has_key?(:lng)
          n[:longitude] = n[:lon] if !n.has_key?(:longitude) && n.has_key?(:lon)

          Arel::Nodes::Within.new(self, n.slice(:radius, :latitude, :longitude))
        end
      else
        Arel::Nodes::Within.new(self, [n,e,s,w])
      end
    end

  end
end
