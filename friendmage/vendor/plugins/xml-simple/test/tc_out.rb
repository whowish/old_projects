#!/usr/bin/env ruby

require 'test/unit'
require '../lib/xmlsimple'

class TC_Out < Test::Unit::TestCase # :nodoc:
  def test_simple_structure
    hash = {
      'opt' => [
        {
          'x' => [ { 'content'=> 'text1'} ],
          'y' => [ { 'content'=> 'text2'} ]
        }
      ]
    }
    expected = <<"END_OF_XML"
<opt>
  <opt>
    <x>text1</x>
    <y>text2</y>
  </opt>
</opt>
END_OF_XML

    assert_equal(expected, XmlSimple.xml_out(hash))
  end

  def test_keep_root
    hash = {
      'opt' => [
        {
          'x' => [ { 'content'=> 'text1'} ],
          'y' => [ { 'content'=> 'text2'} ]
        }
      ]
    }
    expected = <<"END_OF_XML"
<opt>
  <x>text1</x>
  <y>text2</y>
</opt>
END_OF_XML

    assert_equal(expected, XmlSimple.xml_out(hash, { 'keep_root' => true }))
  end

  def test_original
    hash = {
      'logdir'        => '/var/log/foo/',
      'debugfile'     => '/tmp/foo.debug',

      'server'        => {
        'sahara'        => {
          'osversion'     => '2.6',
          'osname'        => 'solaris',
          'address'       => [ '10.0.0.101', '10.0.1.101' ]
        },

        'gobi'          => {
          'osversion'     => '6.5',
          'osname'        => 'irix',
          'address'       => '10.0.0.102'
        },

        'kalahari'      => {
          'osversion'     => '2.0.34',
          'osname'        => 'linux',
          'address'       => [ '10.0.0.103', '10.0.1.103' ]
        }
      }
    }
    puts XmlSimple.xml_out(hash)
  end

  def test_xyz
    hash = {
      'abc' => [
        {
          'z' => ['ZZZ', {}, {}]
        }
      ],
      'b'   => [
        {
          'c' => ['Eins', 'Eins', 'Zwei']
        },
        {
          'c' => [
            'Drei',
            'Zwei',
            { 'd' => [ 'yo' ] }
          ]
        }
      ],
      'xyz'  => [ 'Hallo' ],
      'att'  => [ { 'test' => '42' } ],
      'att2' => [ { 'test' => '4711', 'content' => 'CONTENT' } ],
      'element' => [
        {
          'att'     => '1',
          'content' => 'one'
        },
        {
          'att'     => '2',
          'content' => 'two'
        },
        {
          'att'     => '3',
          'content' => 'three'
        },
      ],
    }
    puts XmlSimple.xml_out(hash)
  end
end
