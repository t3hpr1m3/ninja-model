require 'ninja_model'

class <%= class_name %> < NinjaModel::Base
<%- attributes.each do |a| -%>
  attribute :<%= a.name %>, :<%= a.type %>
<%- end -%>
end
