require 'bindata'
require 'pio/ethernet_header'
require 'pio/ipv4_header'
require 'pio/open_flow'
require 'pio/parse_error'

# Base module.
module Pio
  # OpenFlow 1.0 Packet-In message
  class PacketIn
    # Why is this packet being sent to the controller?
    # (enum ofp_packet_in_reason)
    class Reason < BinData::Primitive
      REASONS = { no_match: 0, action: 1 }

      uint8 :reason

      def get
        REASONS.invert.fetch(reason)
      end

      def set(value)
        self.reason = REASONS.fetch(value)
      end
    end

    # Message body of Packet-In.
    class Body < BinData::Record
      endian :big

      uint32 :buffer_id
      uint16 :total_len, value: -> { raw_data.length }
      uint16 :in_port
      reason :reason
      uint8 :padding
      hide :padding
      string :raw_data, read_length: :total_len

      def empty?
        false
      end

      def length
        10 + raw_data.length
      end
    end

    # Pio::PacketIn#raw_data parser
    class DataParser
      # Ethernet header parser
      class EthernetHeaderParser < BinData::Record
        include EthernetHeader

        endian :big

        ethernet_header
        rest :payload
      end

      # IPv4 packet parser
      class IPv4Packet < BinData::Record
        include EthernetHeader
        include IPv4Header

        endian :big

        ethernet_header
        ipv4_header

        uint16 :transport_source_port
        uint16 :transport_destination_port
        rest :rest
      end

      # rubocop:disable MethodLength
      def self.read(raw_data)
        ethernet_header = EthernetHeaderParser.read(raw_data)
        case ethernet_header.ether_type
        when 0x0800
          IPv4Packet.read raw_data
        when 0x0806
          Pio::Arp.read raw_data
        when 0x88cc
          Pio::Lldp.read raw_data
        else
          fail 'Failed to parse packet_in data.'
        end
      end
      # rubocop:enable MethodLength
    end
  end

  OpenFlow::Message.factory(PacketIn, OpenFlow::PACKET_IN) do
    def_delegators :body, :buffer_id
    def_delegators :body, :total_len
    def_delegators :body, :in_port
    def_delegators :body, :reason
    def_delegators :body, :raw_data

    attr_accessor :datapath_id
    alias_method :dpid, :datapath_id
    alias_method :dpid=, :datapath_id=

    def data
      @data ||= PacketIn::DataParser.read(raw_data)
    end

    def lldp?
      data.is_a? Lldp
    end

    def method_missing(method, *args)
      data.__send__ method, *args
    end
  end
end
