# YAML::Mapping and YAML::Sequence are both collections, in accordance
# with the recommended YAML specs, this class serves as a common base
# class for them.
#
# NOTE: At this point there is no shared behavior.
abstract class YAML::Collection < YAML::Node
end
