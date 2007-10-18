Module.class_eval do
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
    class_eval(<<-EOS, __FILE__, __LINE__)
      def #{method_name}
        class << self; attr_reader :#{method_name}; end
        @#{method_name} = eval(%(#{value}))
      end
    EOS
  end
end