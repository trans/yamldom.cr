# Ideally YAML::Mapping and YAML::Sequence would have YAML::Collection
# as a common base class (in accordance with recommended YAML specs),
# but there doesn't seem to be anything the two classes can actually
# share in the Crystal implmentation.
#
# Until we have something concrete to share, this is not used.
#
# TODO: Is there anything Sequence and Mapping can share?
abstract class YAML::Collection < YAML::Node

end
