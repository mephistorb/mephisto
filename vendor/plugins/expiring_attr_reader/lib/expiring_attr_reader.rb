module ExpiringAttrReader
  # Creates an expiring method that is called once, and overwrites itself so future calls are faster.  It does this
  # by setting an instance variable and an attr_reader on the singleton class.  Other instances of this object are
  # not affected.
  #
  # (example taken from http://redhanded.hobix.com/inspect/methodsThatSelfDestruct.html)
  #   class Hit
  #     expiring_attr_reader :country, %(`geoiplookup #{@ip}`.chomp.gsub(/^GeoIP Country Edition: /,""))
  #
  #     def initialize(ip)
  #       @ip = ip
  #     end
  #   end
  #
  # A better idea would be to refactor the expensive code into a method:
  #
  #   class Hit
  #     expiring_attr_reader :country, "self.class.geoiplookup @ip"
  #
  #     def initialize(ip)
  #       @ip = ip
  #     end
  #
  #     def self.geoiplookup(ip)
  #       `geoiplookup #{ip}`.chomp.gsub(/^GeoIP Country Edition: /,"")
  #     end
  #   end
  def expiring_attr_reader(method_name, value)
    var_name    = method_name.to_s.gsub(/\W/, '')
    class_eval(<<-EOS, __FILE__, __LINE__)
      def #{method_name}
        def self.#{method_name}; @#{var_name}; end
        @#{var_name} ||= eval(%(#{value}))
      end
    EOS
  end
end