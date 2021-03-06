@open_flow10
Feature: Pio::SetEtherDestinationAddress

  Scenario: new('11:22:33:44:55:66')
    When I try to create an OpenFlow action with:
      """
      Pio::SetEtherDestinationAddress.new('11:22:33:44:55:66')
      """
    Then it should finish successfully
    And the action has the following fields and values:
      | field       |             value |
      | action_type |                 5 |
      | length      |                16 |
      | mac_address | 11:22:33:44:55:66 |


