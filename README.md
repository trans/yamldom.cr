# YAML::Representation

The YAML Representation library provides an alternate YAML parser that preserves
parser information lossed when using the normal parser. This it is an intermediate
represention at a stage of parsing just prior to a final native representation. 
In particular `tag` information is preserved and accessable.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  yaml_rep:
    github: trans/yaml_rep
```


## Usage


```crystal
require "yaml_rep"

yaml = <<-YAML
--- !foo
This is an example.
YAML

document = YAML::Representation.parse(yaml)
document.tag  #=> "!foo"
```


## Development

If you'd like to help this project improve, familiarize yourself witht the YAML sepcification
and have at it.


## Contributing

1. Fork it ( https://github.com/[your-github-name]/yaml_node_parser/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [trans](https://github.com/trans) trans - creator, maintainer
