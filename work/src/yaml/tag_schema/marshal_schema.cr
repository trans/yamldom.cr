# The MarshalSchema can construct and serialize any Crystal object in
# its entirety. The complete state of an object -- all it's instance
# variables -- are stored upon dumping and restored upon loading.
#
# Be careful with this schema! Compared to the others, which are limited
# to to core data types, this schema opens up an application to potential
# security holes.
#
class YAML::MarshalSchema < YAML::TagSchema

  # TODO

end
