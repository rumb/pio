require 'pio/open_flow'
require 'pio/open_flow13/actions'
require 'pio/open_flow13/buffer_id'

# Base module.
module Pio
  module OpenFlow13
    # OpenFlow 1.3 PacketOut message parser and generator
    class PacketOut < OpenFlow::Message
      # Packet's input port or :controller
      class InPort < BinData::Primitive
        CONTROLLER = 0xfffffffd

        endian :big
        uint32 :in_port

        def get
          (in_port == CONTROLLER) ? :controller : in_port
        end

        def set(value)
          self.in_port = (value == :controller ? NO_CONTROLLER : value)
        end
      end

      # OpenFlow 1.3 PacketOut message body
      class Body < BinData::Record
        endian :big

        buffer_id :buffer_id
        in_port :in_port
        uint16 :actions_length, initial_value: -> { actions.binary.length }
        string :padding, length: 6
        actions :actions, length: :actions_length
        string :raw_data,
               read_length: -> { _length - 24 - actions_length }

        def length
          10 + padding.length + actions_length + raw_data.length
        end

        def data
          @data ||= Pio::Parser.read(raw_data)
        end

        def method_missing(method, *args)
          data.__send__(method, *args).snapshot
        end
      end

      # OpenFlow 1.3 PacketOut message body
      class Format < BinData::Record
        extend OpenFlow::Format

        header version: 4, message_type: 13
        body :body
      end

      body_option :buffer_id
      body_option :in_port
      body_option :actions
      body_option :raw_data
    end
  end
end
