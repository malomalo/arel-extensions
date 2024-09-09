module Arel
  module GISPredications

    def intersects(value)
      Arel::Nodes::Intersects.new(self, geometry(value))
    end

    def within(value)
      Arel::Nodes::Within.new(self, geometry(value))
    end

    private

    def geometry(value)
      case value
      in Arel::Nodes::Node then value
      in RGeo::Geos::CAPIGeometryMethods then Arel::Nodes::Geometry.new(value)
      in ::String
        factory = RGeo::Geos.factory(:srid => 4326)
        result = if value[0,1] == "\x00" || value[0,1] == "\x01" || value[0,4] =~ /[0-9a-fA-F]{4}/
          RGeo::WKRep::WKBParser.new(factory, support_ewkb: true, default_srid: 4326).parse(value)
        else
          RGeo::WKRep::WKTParser.new(factory, support_ewkt: true, default_srid: 4326).parse(value)
        end
        Arel::Nodes::Geometry.new(result)
      in Hash
        Arel::Nodes::Geometry.new(RGeo::GeoJSON.decode(value))
      end
    end
  end
end
