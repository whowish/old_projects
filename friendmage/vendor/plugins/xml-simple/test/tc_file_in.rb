#!/usr/bin/env ruby

require 'test/unit'
require '../lib/xmlsimple'

class TC_File_In < Test::Unit::TestCase # :nodoc:
  def test_original
    config = XmlSimple.new
    expected = {
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
    assert_equal(expected, config.xml_in('files/original_pod.xml', { 'force_array' => false, 'key_attr' => %w(name) }))

    expected = {
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
          'address'       => [ '10.0.0.102' ]
        },

        'kalahari'      => {
          'osversion'     => '2.0.34',
          'osname'        => 'linux',
          'address'       => [ '10.0.0.103', '10.0.1.103' ]
        }
      }
    }
    assert_equal(expected, config.xml_in('files/original_pod.xml', { 'key_attr' => %w(name) }))
    assert_equal(expected, config.xml_in('files/original_pod.xml', { 'key_attr' => 'name' }))
  end

  def test_keep_root
    config = XmlSimple.new
    expected = {
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
    assert_equal(expected, config.xml_in('files/to_hash.xml'))

    config = XmlSimple.new
    expected = {
      'a' => [
        {
          'att' => [
            {
              'test' => '42'
            }
          ],
          'abc' => [
            {
              'z' => [
                'ZZZ',
                {},
                {}
              ]
            }
          ],
          'att2' => [
            {
              'content' => 'CONTENT',
              'test' => '4711'
            }
          ],
          'b' => [
            {
              'c' => [
                'Eins',
                'Eins',
                'Zwei'
              ]
            },
            {
              'c' => [
                'Drei',
                'Zwei',
                {
                  'd' => [
                    'yo'
                  ]
                }
              ]
            }
          ],
          'element' => [
            {
              'att' => '1',
              'content' => 'one'
            },
            {
              'att' => '2',
              'content' => 'two'
            },
            {
              'att' => '3',
              'content' => 'three'
            }
          ],
          'xyz' => [
            'Hallo'
          ]
        }
      ]
    }
    assert_equal(expected, config.xml_in('files/to_hash.xml', { 'keep_root' => true }))

    config = XmlSimple.new({ 'keep_root' => true })
    assert_equal(expected, config.xml_in('files/to_hash.xml'))

    expected = {
      'abc' => [
        {
          'z' => [ 'ZZZ' ]
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
    assert_equal(expected, XmlSimple.xml_in('files/to_hash.xml', { 'suppress_empty' => true }))

    config = XmlSimple.new({ 'suppress_empty' => true })
    assert_equal(expected, config.xml_in('files/to_hash.xml'))
  end

  def test_force_content
    config = XmlSimple.new
    expected = {
      'x' => [ 'text1' ],
      'y' => [ { 'a' => '2', 'content' => 'text2' } ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml'))

    expected = {
      'x' => 'text1',
      'y' => { 'a' => '2', 'content' => 'text2' }
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => false }))

    expected = {
      'x' => [ {             'content' => 'text1' } ],
      'y' => [ { 'a' => '2', 'content' => 'text2' } ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_content' => true }))

    expected = {
      'x' => {             'content' => 'text1' },
      'y' => { 'a' => '2', 'content' => 'text2' }
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => false, 'force_content' => true }))

    expected = {
      'x' => [ {             'text' => 'text1' } ],
      'y' => [ { 'a' => '2', 'text' => 'text2' } ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', {'content_key' => 'text', 'force_content' => true}))

    expected = {
      'x' => [ 'text1' ],
      'y' => [ { 'a' => '2', 'text' => 'text2' } ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', {'content_key' => 'text', 'force_content' => false}))

    expected = {
      'x' => 'text1',
      'y' => { 'a' => '2', 'text' => 'text2' }
    }
    assert_equal(expected, config.xml_in('files/opt.xml', {
      'force_array'   => false,
      'content_key'   => 'text',
      'force_content' => false
    }))
  end

  def test_force_array
    config = XmlSimple.new
    expected = {
      'x' => ['text1'],
      'y' => [{ 'a' => '2', 'content' => 'text2' }]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => true }))

    expected = {
      'x' => ['text1'],
      'y' => { 'a' => '2', 'content' => 'text2' }
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => ['x']}))

    expected = {
      'x' => 'text1',
      'y' => [{ 'a' => '2', 'content' => 'text2' }]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => ['y']}))

    expected = {
      'x' => ['text1'],
      'y' => [{ 'a' => '2', 'content' => 'text2' }]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => ['x', 'y']}))

    expected = {
      'x' => 'text1',
      'y' => { 'a' => '2', 'content' => 'text2' }
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => []}))

    expected = {
      'x' => 'text1',
      'y' => { 'a' => '2', 'content' => 'text2' }
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_array' => false }))
  end

  def test_no_attr
    config = XmlSimple.new
    expected = {
      'x' => [ { 'a' => '1', 'b' => '2', 'content' => 'Hello' } ],
      'y' => [ { 'c' => '5',             'content' => 'World' } ],
      'z' => [ { 'inner' => [ 'Inner' ] } ],
    }
    assert_equal(expected, config.xml_in('files/att.xml'))

    expected = {
      'x' => [ 'Hello' ],
      'y' => [ 'World' ],
      'z' => [ { 'inner' => [ 'Inner' ] } ],
    }
    assert_equal(expected, config.xml_in('files/att.xml', { 'no_attr' => true}))

    config = XmlSimple.new
    expected = {
      'x' => [ 'text1' ],
      'y' => [ 'text2' ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'no_attr' => true}))

    expected = {
      'x' => [ { 'content'=> 'text1'} ],
      'y' => [ { 'content'=> 'text2'} ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'force_content' => true, 'no_attr' => true}))

    config = XmlSimple.new
    expected = {
      'opt' => [
        {
          'x' => [ { 'content'=> 'text1'} ],
          'y' => [ { 'content'=> 'text2'} ]
        }
      ]
    }
    assert_equal(expected, config.xml_in('files/opt.xml', { 'keep_root' => true, 'force_content' => true, 'no_attr' => true}))
  end

  def test_minimum
    config = XmlSimple.new
    assert_equal({}, config.xml_in('files/empty.xml'))
    assert_equal({'config' => [{}]}, config.xml_in('files/empty.xml', { 'keep_root' => true }))

    config = XmlSimple.new
    assert_equal('Hello', config.xml_in('files/empty_and_text.xml'))
    assert_equal({'config' => ['Hello']}, config.xml_in('files/empty_and_text.xml', { 'keep_root' => true}))

    config = XmlSimple.new
    assert_equal({ 'att' => 'Hello'}, config.xml_in('files/empty_att.xml'))
    assert_equal({'config' => [ {'att' => 'Hello'} ]}, config.xml_in('files/empty_att.xml', { 'keep_root' => true }))

    config = XmlSimple.new
    assert_equal({ 'att' => 'Hello', 'content' => 'Test'}, config.xml_in('files/empty_att_text.xml'))
    assert_equal({
      'config' => [
        {
          'att'     => 'Hello',
          'content' => 'Test'
        }
      ]
    }, config.xml_in('files/empty_att_text.xml', { 'keep_root' => true }))
  end

  def test_key_attr
    config = XmlSimple.new
    expected = {
      'user' => {
        'stty' => {
          'fullname' => 'Simon T Tyson',
          'login'    => 'stty'
        },
        'grep' => {
          'fullname' => 'Gary R Epstein',
          'login'    => 'grep'
        }
      }
    }
    assert_equal(expected, config.xml_in('files/keyattr.xml', { 'key_attr' => { 'user' => '+login' } }))

    expected = {
      'user' => {
        'stty' => {
          'fullname' => 'Simon T Tyson',
          '-login'   => 'stty'
        },
        'grep' => {
          'fullname' => 'Gary R Epstein',
          '-login'   => 'grep'
        }
      }
    }
    assert_equal(expected, config.xml_in('files/keyattr.xml', { 'key_attr' => { 'user' => '-login' } }))
  end

end

