#!/usr/bin/env ruby

require 'test/unit'
require '../lib/xmlsimple'

# This test class is named after Curtis Schofield, who
# reported the bug whose absence is tested by this class :-)
class TC_Curtis < Test::Unit::TestCase # :nodoc:
  def test_empty_attributes
    expected = {
      "logdir" => "/var/log/foo/",
      "server" => [
        {
          "name" => "sahara",
          "osversion" => "2.6",
          "osname" => "solaris",
          "address" => [ "10.0.0.101", "10.0.1.101" ]
        },
        {
          "name" => "gobi",
          "osversion" => "6.5",
          "osname" => "irix",
        },
        {
          "name" => "kalahari",
          "osversion" => "2.0.34",
          "osname" => "linux",
          "address" => [ "10.0.0.103", "10.0.1.103" ]
        }
      ],
      "debugfile" => "/tmp/foo.debug"
    }
    xml = XmlSimple.xml_in('files/curtis.xml', { 'NormalizeSpace' => 2 })
    assert_equal(expected, xml)
    xml = XmlSimple.xml_in('files/curtis.xml', { 'SuppressEmpty' => true })
    assert_equal(expected, xml)
  end

  def test_with_noattr
    expected = {
      "server" => [
        {
          "address" => [ "10.0.0.101", "10.0.1.101" ]
        },
        {
          "address" => [ "10.0.0.103", "10.0.1.103" ]
        }
      ],
    }
    xml = XmlSimple.xml_in('files/curtis.xml', { 'NoAttr' => true, 'SuppressEmpty' => true })
    assert_equal(expected, xml)
  end
end

# vim:sw=2
