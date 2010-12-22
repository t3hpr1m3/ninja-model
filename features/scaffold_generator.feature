Feature: NinjaModel Scaffold Generator
	In order to manage a resource persisted on some non-standard medium
	As a rails developer
	I want to generate a model, controller, and views for that resource

	Scenario: Generate scaffold for simple resource
		Given a new Rails app
		When I run "rails g ninja_model:scaffold Product name:string category:integer price:float"
		Then I should see the following files
			| app/models/product.rb						|
			| app/controllers/products_controller.rb	|
			| app/helpers/products_helper.rb			|
			| app/views/products/index.html.erb			|
			| app/views/products/show.html.erb			|
			| app/views/products/new.html.erb			|
			| app/views/products/edit.html.erb			|
			| app/views/products/_form.html.erb			|
		And I should see "resources :products" in file "config/routes.rb"
