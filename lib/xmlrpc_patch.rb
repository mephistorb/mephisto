module XMLRPC
  module Convert
    def self.dateTime(str)
      case str
      when /^(-?\d\d\d\d)-?(\d\d)-?(\d\d)T(\d\d):(\d\d):(\d\d)(?:Z|([+-])(\d\d):?(\d\d))?$/
        a = [$1, $2, $3, $4, $5, $6].collect{|i| i.to_i}
        if $7
          ofs = $8.to_i*3600 + $9.to_i*60
          ofs = -ofs if $7=='+'
          # Ruby's original method call has Time.utc(a.reverse) here
          # which totally doesn't make sense since a) Time#utc doesn't take
          # an array as its argument and b) year is the first argument, so
          # why reverse it?
          utc = Time.utc(*a) + ofs
          # END OF PATCH
          a = [ utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec ]
        end
        XMLRPC::DateTime.new(*a)
      when /^(-?\d\d)-?(\d\d)-?(\d\d)T(\d\d):(\d\d):(\d\d)(Z|([+-]\d\d):(\d\d))?$/
        a = [$1, $2, $3, $4, $5, $6].collect{|i| i.to_i}
        if a[0] < 70
          a[0] += 2000
        else
          a[0] += 1900
        end
        if $7
          ofs = $8.to_i*3600 + $9.to_i*60
          ofs = -ofs if $7=='+'
          # Ruby's original method call has Time.utc(a.reverse) here
          # which totally doesn't make sense since a) Time#utc doesn't take
          # an array as its argument and b) year is the first argument, so
          # why reverse it?
          utc = Time.utc(*a) + ofs
          # END OF PATCH
          a = [ utc.year, utc.month, utc.day, utc.hour, utc.min, utc.sec ]
        end
        XMLRPC::DateTime.new(*a)
      else
        raise "wrong dateTime.iso8601 format " + str
      end
    end
  end
end