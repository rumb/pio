require 'pio/open_flow10/strip_vlan_header'

describe Pio::StripVlanHeader do
  Given(:strip_vlan_header) { Pio::StripVlanHeader.new }

  describe '#action_type' do
    When(:action_type) { strip_vlan_header.action_type }
    Then { action_type == 3 }
  end

  describe '#length' do
    When(:length) { strip_vlan_header.length }
    Then { length == 8 }
  end

  describe '#to_binary' do
    When(:binary) { strip_vlan_header.to_binary }
    Then { binary.length == 8 }
  end
end
