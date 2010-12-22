require 'active_support/inflector'
require 'builder'
require 'nokogiri'
require 'ninja-model'

module XmlSetupHelpers
  def setup_xml_datastore(name, attrs)
    @current_directory = File.expand_path("tmp")
    FileUtils.mkdir_p(@current_directory)
    data = ''
    x = Builder::XmlMarkup.new(:target => data)
    x.instruct!
    x.products
    path = File.join(@current_directory, "#{name.pluralize}.xml")
    File.open(path, 'w') { |f| f.write(data + "\n") }

    @model_klass = Class.new(NinjaModel::Base)
    attrs.each do |attr|
        @model_klass.attribute attr['name'], attr['type']
    end
  end

  def add_to_xml_datastore(name, obj)
    path = File.join(@current_directory, "#{name.pluralize}.xml")
    f = File.open(path, 'r')
    doc = Nokogiri::XML(f)
    doc.root.add_child(
      doc.create_element(name) do |node|
        @model_klass.model_attributes.each_key do |k|
          node.add_child(doc.create_element(k, obj[k]))
        end
      end
    )

    f.close
    File.open(path, 'w') { |f| f.write(doc.to_xml) }
  end
end

World(XmlSetupHelpers)
