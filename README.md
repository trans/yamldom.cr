# YAML DOM

**IMPORTANT!!! This project has been shit-canned because Crystal can't polymorph
enumeration over Array and Hash. That makes this kind of API, while already
difficult (because Crystal is a strongly typed language), essentially impossible. 
Sorry kids, you are stuck with pull parsing.**


## Intermediate Representation

[![YAML Process](yamlproc.png)](http://yaml.org/spec/1.2/spec.html#Processing)

The YAML DOM library provides a YAML composer that the models YAML [Intermediate
Representation](). This model preserves information lost when using the
current Crystal "parser". In particular `tag` information is preserved
and accessible.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  yamldom:
    github: trans/yamldom.cr
```

## Usage

First, lets see how we can get the intermediate representation of a YAML document.

```crystal
require "yamldom"

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
doc.value.node(0).to_s   #=> "EXAMPLE"
doc.value.node(0).class  #=> YAML::Scalar
```

We use `#node` to access the node itself. For convenience the usual `#[]` method accesses
the underlying value.

```
doc.value[0]        #=> "EXAMPLE"
doc.value[0].class  #=> String
```

This makes it fairly easy to work with the DOM API.

Lastly note that the value 100 in the document is still a String.

```
doc.value[0]        #=> "100"
```

It isn't an Integer because *composition* is a stage before *construction* in which
the node would be converted to a native data type (and extra information like tag lost).

<!--

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

-->

## Development

If you'd like to help this project improve, familiarize yourself with the
[YAML sepcification](http://yaml.org/spec/1.2/spec.html) and have at it.


## Contributing

1. Fork it ( https://github.com/trans/yamldom/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [trans](https://github.com/trans) trans - creator, maintainer

