#!/usr/bin/env ruby

$VERBOSE = true

$: << "../lib"

require 'test/unit'
require 'zlib'

include Zlib

class ZLibTest < Test::Unit::TestCase

  def test_BufError
    inflater = Zlib::Inflate.new(-Zlib::MAX_WBITS)
    s = ""
    File.open("data/file1.txt.deflatedData") {
      |is|
      while (!inflater.finished?)
        s += inflater.inflate(is.read(1))
      end
    }
    puts s
    assert_equal(File.read("data/file1.txt"), s)
  end
end
