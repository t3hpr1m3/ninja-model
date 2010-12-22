Feature: NinjaModel Model Generator
	In order to manage a resource persisted on some non-standard medium
	As a rails developer
	I want to generate a model, controller, and views for that resource

	Scenario: Generate scaffold for simple resource
		Given a new Rails app
		When I run "rails g ninja_model:model product name:string category:integer price:float"
		Then I should see the following files
			| app/models/product.rb	|
