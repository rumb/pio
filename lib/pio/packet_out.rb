require 'bindata'
require 'pio/open_flow'

# Base module.
module Pio
  # OpenFlow 1.0 Packet-Out message
  class PacketOut
    # Message body of Packet-Out
    class Body < BinData::Record
      endian :big

      uint32 :buffer_id
      uint16 :in_port
      uint16 :actions_len, initial_value: -> { actions.binary.length }
      actions :actions, length: -> { actions_len }
      rest :raw_data

      def empty?
        false
      end

      def length
        8 + actions_len + raw_data.length
      end
    end
  end

  OpenFlow::Message.factory(PacketOut, OpenFlow::PACKET_OUT) do
    def_delegators :body, :buffer_id
    def_delegators :body, :in_port
    def_delegators :body, :actions_len
    def_delegators :body, :actions
    def_delegators :body, :raw_data
  end
end
