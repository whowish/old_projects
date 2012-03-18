#!/usr/bin/env ruby

require 'test/unit'
require '../lib/xmlsimple'
require 'ftools'

# The test cases below are copied from the original Perl version,
# because I wanted to behave the Ruby version exactly as the Perl
# version. I left some comments, that maybe do not make a lot of
# sense in the current Ruby version just to make it easier to find
# changes between the current and future Perl versions of the
# module.
# Please note, that a major difference between the Perl and the Ruby
# version is, that the defaults of the options 'force_array' and
# 'key_attr' have changed.
class TC_Perl_Mem_Share < Test::Unit::TestCase # :nodoc:
  # Wait until the current time is greater than the supplied value
  def pass_time(target)
    while Time::now.to_i <= target
      sleep 1
    end
  end
  
  def test_perl_test_cases
    src_file = 'files/desertnet.src'
    xml_file = 'files/desertnet.xml'
    raise "Test data is missing!" unless File::exist?(src_file)

    # Make sure we can write to the filesystem and check it uses the same
    # clock as the machine we're running on.
    t0   = Time::now.to_i
    file = File.open(xml_file, "w")
    file.close
    t1   = File::mtime(xml_file).to_i
    t2   = Time::now.to_i
    raise "Time moved backwards!" if (t1 < t0) || (t2 < t1)

    # Initialise test data
    expected  = {
      'server' => {
        'sahara' => {
          'osversion' => '2.6',
          'osname'    => 'solaris',
          'address'   => [
            '10.0.0.101',
            '10.0.1.101'
          ]
        },
        'gobi' => {
          'osversion' => '6.5',
          'osname'    => 'irix',
          'address'   => '10.0.0.102'
        },
        'kalahari' => {
          'osversion' => '2.0.34',
          'osname'    => 'linux',
          'address'   => [
            '10.0.0.103',
            '10.0.1.103'
          ]
        }
      }
    }

    File.copy(src_file, xml_file)
    t0 = File::mtime(xml_file)
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'mem_share' })
    assert_equal(expected, opt)

    File.delete(xml_file)
    assert(!File::exist?(xml_file))
    file = File.open(xml_file, "w") # Re-create it (empty)
    file.close
    assert(File::exist?(xml_file))
    t1 = t0 - 1
    File.utime(t1, t1, xml_file)
    t2 = File::mtime(xml_file)
    if (t2 < t0)
      opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'mem_share' })
      assert_equal(expected, opt)
      assert_equal(File::size(xml_file), 0)
    else
      puts "No utime!"
    end
    pass_time(Time::now().to_i)

    # Write some new data to the XML file
    File.open(xml_file, "w") { |file| file.write('<opt one="1" two="2"></opt>' + "\n") }
    # Ensure current time later than file time.
    pass_time(Time::now().to_i)
    opt = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'mem_share' })
    assert_equal({ 'one' => '1', 'two' => '2' }, opt)
    opt['three'] = 3 # Alter the returned structure and retrieve again from cache
    opt2 = XmlSimple.xml_in(xml_file, { 'force_array' => false, 'key_attr' => %w(name key id), 'cache' => 'mem_share' })
    assert_equal(3, opt2['three'])

    # Clean up.
    File.delete(xml_file)
  end
end
