Given /^a new Rails app$/ do
  FileUtils.mkdir_p('tmp')
  system('rails new tmp/rails_app')
  system('ln -s ../../../lib/generators tmp/rails_app/lib/generators').should be_true
  @current_directory = File.expand_path('tmp/rails_app')
end

Given /^a (.*) (.*) data store with the following attributes$/ do |name, type, table|
  @current_datastore_type = type
  send("setup_#{type}_datastore".to_sym, name, table.hashes)
end

Given /^the following list of (.*)$/ do |name, table|
  table.hashes.each do |attrs|
    send("add_to_#{@current_datastore_type}_datastore", name.singularize, attrs)
  end
end
