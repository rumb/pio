require 'bindata'
require 'pio/ethernet_header'
require 'pio/ipv4_header'
require 'pio/udp_header'

module Pio
  # UDP packet format
  class Udp < BinData::Record
    include EthernetHeader
    include IPv4Header
    include UdpHeader

    endian :big
    ethernet_header ether_type: EthernetHeader::ETHER_TYPE_IP
    ipv4_header ip_protocol: IPv4Header::IP_PROTOCOL_UDP
    udp_header
    rest :udp_payload
  end
end
