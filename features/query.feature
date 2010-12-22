#Feature: Query
#	In order to avoid writing a bunch of custom search logic
#	As a rails developer
#	I want to be able to define a class as a subclass of NinjaModel::Base and automatically have access to search capabilities
#
#	Scenario: Search an xml file
#		Given a products xml data store with the following attributes
#			| name	| type		|
#			| name	| :string	|
#			| price	| :float	|
#		And the following list of products
#			| name	| price	|
#			| shirt	| 10.99	|
#			| tie	| 5.50	|
#			| hat	| 9.75	|
#		When I search for the product with a name of "hat"
#		Then I should get a product with a price of 9.99
