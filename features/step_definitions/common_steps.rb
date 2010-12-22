When /^I run "([^\"]*)"$/ do |command|
  system("cd #{@current_directory} && #{command}").should be_true
end

Then /^I should see the following files$/ do |table|
  table.raw.flatten.each do |path|
    File.should exist(File.join(@current_directory, path))
  end
end

Then /^I should see "(.*)" in file "([^\"]*)"$/ do |content, relative_path|
  path = File.join(@current_directory, relative_path)
  File.should exist(path)
  File.readlines(path).join.should include(content)
end
