Feature: parent associates with dependent
  In order to denormalize a 1 to 1 relationship while maintaining a useful model of the domain
  As a rails developer
  I want to be able to access a depent model event though it's attributes are stored in the parent model's db table
  
  Scenario: accessing a dependent model from a parent
    Given a parent model class and instance
    And a child model class and instance
    When I access the association of a parent model instance
    Then it should return the child instance of the parent instance
