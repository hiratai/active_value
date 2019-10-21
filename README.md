# ActiveValue

Model for non database. However like ActiveRecord.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_value'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_value


## Usage

```ruby
class QuestionType < ActiveValue::Base
 
  attr_accessor :id, :symbol, :name
  
  Checkbox  = new id: 1, symbol: :checkbox, name: "Check Box"
  Radio     = new id: 2, symbol: :radio,    name: "Radio Button"
  Selectbox = new id: 3, symbol: :select,   name: "Select Box"
  Text      = new id: 4, symbol: :text,     name: "Text Box"
  TextArea  = new id: 5, symbol: :textarea, name: "Text Area"
  
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hiratai/active_value.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

