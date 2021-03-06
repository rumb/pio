require 'pio/open_flow'

# Base module.
module Pio
  # OpenFlow 1.3 messages
  module OpenFlow13
    # Features Request and Reply message.
    class Features
      # Features Request message.
      class Request < OpenFlow::Message
        # Features Request message format.
        class Format < BinData::Record
          extend OpenFlow::Format

          header version: 4, message_type: 5
          string :body, value: ''
        end
      end
    end
  end
end
