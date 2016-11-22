module YAML

  alias Kind = Scalar | Sequence | Mapping

  alias Value = String | Array(Node) | Hash(Node,Node)

end
