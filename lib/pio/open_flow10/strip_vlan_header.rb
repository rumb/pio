require 'bindata'
require 'forwardable'

module Pio
  # An action to strip the 802.1q header.
  class StripVlanHeader
    # OpenFlow 1.0 OFPAT_STRIP_VLAN action format.
    class Format < BinData::Record
      endian :big

      uint16 :action_type, value: 3
      uint16 :action_length, value: 8
      uint32 :padding
      hide :padding
    end

    def self.read(raw_data)
      allocate.tap do |strip_vlan|
        strip_vlan.instance_variable_set :@format, Format.read(raw_data)
      end
    end

    extend Forwardable

    def_delegators :@format, :action_type
    def_delegator :@format, :action_length, :length
    def_delegator :@format, :to_binary_s, :to_binary

    def initialize
      @format = Format.new
    end
  end
end
