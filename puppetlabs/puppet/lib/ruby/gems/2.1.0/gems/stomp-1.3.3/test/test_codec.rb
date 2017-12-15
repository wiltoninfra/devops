# -*- encoding: utf-8 -*-

if Kernel.respond_to?(:require_relative)
  require_relative("test_helper")
else
  $:.unshift(File.dirname(__FILE__))
  require 'test_helper'
end

=begin

  Main class for testing Stomp::HeadreCodec methods.

=end
class TestCodec < Test::Unit::TestCase
  include TestBase
  
  def setup
    @conn = get_connection()
    # Data for multi_thread tests
    @max_threads = 20
    @max_msgs = 100
  end

  def teardown
    @conn.disconnect if @conn.open? # allow tests to disconnect
  end

  # Test that the codec does nothing to strings that do not need encoding.
  def test_1000_check_notneeded
    test_data = [
      "a",
      "abcdefghijklmnopqrstuvwxyz",
      "ªºÀÁ",
      "AÇBØCꞇDẼ",
      "ªºÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ" + 
                "ĀāĂăĄąĆćĈĉĊċČčĎďĐđĒēĔĕĖėĘęĚěĜĝĞğĠġǄǅǆǇǈǼǽǾǿȀȁȂȃȌȍȒɰɵɲɮᴘᴤᴭᴥᵻᶅ" +
                "ᶑṆṌṕṽẄẂỚỘⅱⅲꜨꝐꞂ",
      ]
    #
    test_data.each do |s|
      #
      s_decoded_a = Stomp::HeaderCodec::decode(s)
      assert_equal s, s_decoded_a, "Sanity check decode: #{s} | #{s_decoded_a}"
      s_reencoded = Stomp::HeaderCodec::encode(s_decoded_a)
      assert_equal s_decoded_a, s_reencoded, "Sanity check reencode: #{s_decoded_a} | #{s_reencoded}"
      #
    end
  end

  # Test the basic encoding / decoding requirements.
  def test_1010_basic_encode_decode
    test_data = [
    	[ "\\\\\\\\", "\\\\" ], # [encoded, decoded]
    	[ "\\\\", "\\" ], # [encoded, decoded]
    	["\\n", "\n"],
    	["\\r", "\r"],
	    ["\\c", ":"],
	    ["\\\\\\n\\c", "\\\n:"],
	    ["\\\\\\r\\c", "\\\r:"],
	    ["\\c\\n\\\\", ":\n\\"],
	    ["\\c\\r\\\\", ":\r\\"],
	    ["\\\\\\c", "\\:"],
	    ["c\\cc", "c:c"],
	    ["n\\nn", "n\nn"],
	    ["r\\rr", "r\rr"],
      ]
    #
    test_data.each do |s|
      encoded_orig = s[0]
      decoded_orig = s[1]

      # Part 1
      s_decoded_a = Stomp::HeaderCodec::decode(encoded_orig)
      assert_equal decoded_orig, s_decoded_a, "Sanity check decode: #{decoded_orig} | #{s_decoded_a}"
      #
      s_encoded_a = Stomp::HeaderCodec::encode(decoded_orig)
      assert_equal encoded_orig, s_encoded_a, "Sanity check encode: #{encoded_orig} | #{s_encoded_a}"

      # Part 2
      s_decoded_b = Stomp::HeaderCodec::decode(s_encoded_a)
      assert_equal decoded_orig, s_decoded_b, "Sanity check 2 decode: #{decoded_orig} | #{s_decoded_b}"
      #
      s_encoded_b = Stomp::HeaderCodec::encode(s_decoded_a)
      assert_equal encoded_orig, s_encoded_b, "Sanity check  2 encode: #{encoded_orig} | #{s_encoded_b}"
    end
  end

  # Test more complex strings with the codec.
  def test_1020_fancier
    test_data = [
    	[ "a\\\\b", "a\\b" ],  # [encoded, decoded]
      [ "\\\\\\n\\c", "\\\n:" ],
      [ "\\\\\\r\\c", "\\\r:" ],
      [ "\\rr\\\\\\n\\c", "\rr\\\n:" ],
      ]
    #
    test_data.each do |s|
      encoded_orig = s[0]
      decoded_orig = s[1]

      # Part 1
      s_decoded_a = Stomp::HeaderCodec::decode(encoded_orig)
      assert_equal decoded_orig, s_decoded_a, "Sanity check decode: #{decoded_orig} | #{s_decoded_a}"
      #
      s_encoded_a = Stomp::HeaderCodec::encode(decoded_orig)
      assert_equal encoded_orig, s_encoded_a, "Sanity check encode: #{encoded_orig} | #{s_encoded_a}"

      # Part 2
      s_decoded_b = Stomp::HeaderCodec::decode(s_encoded_a)
      assert_equal decoded_orig, s_decoded_b, "Sanity check 2 decode: #{decoded_orig} | #{s_decoded_b}"
      #
      s_encoded_b = Stomp::HeaderCodec::encode(s_decoded_a)
      assert_equal encoded_orig, s_encoded_b, "Sanity check  2 encode: #{encoded_orig} | #{s_encoded_b}"
    end
  end

end # of class

