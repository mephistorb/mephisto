module SQLite3
  class ResultSet
    # Add taint to data returned from SQLite3 database.  This is based on a
    # patch by Koji Shimada:
    # http://rubyforge.org/tracker/index.php?func=detail&aid=20325&group_id=254&atid=1045
    def next_with_tainting
      row = next_without_tainting
      case row
      when Hash
        row.each {|key, value| value.taint }
      when Array
        row.each {|column| column.taint }
      end
      row
    end
    alias_method_chain :next, :tainting
  end
end
