# YAML Intermediate Representation

[![YAML Process](yamlproc.png)](http://yaml.org/spec/1.2/spec.html#Processing)

The current Crystal YAML library produces a quasi-native/intermediate-representation.
The result is native in that YAML Sequences are converted to Array, and YAML Mappings
are converted to Hash, but it is still an intermediate representation because
YAML Scalars remain just Strings.

The YAML Representation library provides a true YAML composer that preserves
information lost when using the current Crystal "parser". This it is an
intermediate representation at a stage of loading just prior to a final
native construction. In particular `tag` information is preserved and
accessible. With this proper intermediate representation this library
can also provide standard native construction.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  yaml_rep:
    github: trans/yaml_rep.cr
```


## Usage

First, lets see how we can get the intermediate representation of a YAML document.

```crystal
require "yaml_rep"

yaml = <<-YAML
--- !foo
- EXAMPLE
- 100
YAML

doc = YAML.compose(yaml)
doc.tag    #=> "!foo"
doc.value  #=> ["EXAMPLE", "100"]
doc.class  #=> YAML::Sequence
```

There are a few things to notice here. First we were able to get the tag.
Second, the class of object compose retuirns a `YAML::Node` and there are
three types of such nodes, `YAML::Scalar`, `YAML::Sequence` and `YAML::Mapping`.
If we look at the elements inside the sequence we will see it is made up
of other nodes.

```
doc.value[0]        #=> "EXAMPLE"
doc.value[0].class  #=> YAML::Scalar
```

Lastly, note that the value 100 in the document is still stored internally as a String.
It isn't an Integer because *composition* is a stage before *construction* -- in which
node would be converted to native data types. But, that also means additional information
such as the tag would be lost.

```
data = YAML.construct(doc)
data  #=> ["EXAMPLE", 100]
```

Okay, so what's going on under hood? How does this all work. We use a called the
*tag schema*. The base class is `YAML::TagSchema` and there are few subclasses that
actually do the dirty work of figuring out how to construct YAML into data and deconstruct
-- actually called representing -- data into YAML. The primary and thus default tag
schema is `YAML::CoreSchema`. It encodes the full YAML 1.2 standard.

Now here is the great thing about tag schemas. They allow us to control the tags of classes
as we see fit including out own custom tags.

```
class MyTagSchema < YAML::CoreSchema
  def construct(node : YAML::Scalar)
    case node.tag
    when "!foo"
      Foo.new(node.value)
    else
      super(node)
    end
  end

  def represent(value : Foo)
    YAML::Scalar.new("!foo", value.to_s)
  end
end
```

Now ...

```
yaml = <<-YAML
--- !foo
Try Me
YAML

YAML.load(example, MyTagSchema.new)
```

Or a minor shortcut.

```
foo = MyTagSchema.load(example)
foo.class #=> Foo
```


## Development

If you'd like to help this project improve, familiarize yourself with the
[YAML sepcification](http://yaml.org/spec/1.2/spec.html) and have at it.


## Contributing

1. Fork it ( https://github.com/[your-github-name]/yaml_node_parser/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [trans](https://github.com/trans) trans - creator, maintainer
