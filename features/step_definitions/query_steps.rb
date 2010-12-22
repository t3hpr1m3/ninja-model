When /^I search for the (.*) with a (.*) of "(.*)"$/ do |name, attr, val|
  @model_klass.where(attr.to_sym => val).first
end
