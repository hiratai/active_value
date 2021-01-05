# ActiveValue

![TEST](https://img.shields.io/github/workflow/status/hiratai/active_value/Test?style=for-the-badge)
![RELEASE_VERSION](https://img.shields.io/github/v/release/hiratai/active_value?style=for-the-badge)
![GEM_VERSION](https://img.shields.io/gem/v/active_value?style=for-the-badge)
![LICENSE](https://img.shields.io/github/license/hiratai/active_value?style=for-the-badge)

#### Overviews

ActiveValue::Base is base class for immutable value object that has interfaces like ActiveRecord.  
In a class inherited this class, constant variables get the behavior like records of ActiveRecord.  

#### Supported Verisons

Support Ruby 2.3 or later  
Unit tests are passed with Ruby [2.3, 2.5, 2,7, 3.0] on GitHub Actions

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_value'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_value


## Usage

1. Define the target class inherited from ActiveValue::Base
2. List attributes of the object using attr_accessor
3. Declare constant variables as this instance in this class

```ruby
class FormCategory < ActiveValue::Base

  attr_accessor :id, :symbol, :name

  CHECK_BOX  = new id: 1, symbol: :checkbox, name: "Check Box"
  RADIO      = new id: 2, symbol: :radio,    name: "Radio Button"
  SELECT_BOX = new id: 3, symbol: :select,   name: "Select Box"
  TEXT       = new id: 4, symbol: :text,     name: "Text Box"
  TEXTAREA   = new id: 5, symbol: :textarea, name: "Text Area"

end
```
Then, constant variables in the class can be accessed by following methods.
```ruby
FormCategory.find(1)
=> <#FormCategory id: 1, symbol: :checkbox, name: "Check Box" >
# Also can be accessed by FormCategory::CHECK_BOX

FormCategory.find_by(symbol: :checkbox).name
=> "Check Box"

FormCategory.find(1).checkbox?
=> true

FormCategory.find(2).to_h
=> { :id => 2, :symbol => :radio, :name => "Radio Button" }
```
Getter methods for multiple objects are also provided.
```ruby
FormCategory.all
=> [<#FormCategory id: 1, symbol: :checkbox, name: "Check Box" >, <#FormCategory id: 2, symbol: :radio, name: "Radio Button" >, ...]

FormCategory.pluck(:id, :name)
=> [[1, "Check Box"], [2, "Radio Button"], [3, "Select Box"], ...]

# Undefined method calls delegate to the all method.
FormCateory.select { |category| category.name.start_with("Text") }
=> [<#FormCategory id: 4, symbol: :text, name: "Text Box" >, <#FormCategory id: 5, symbol: :textarea, name: "Text Area" >]
```

## Specified Attributes

`id` and `symbol` are specified attributes. (not required)
- If `id` attribute is defined, you can access a instance using `find` class method.  
- If `symbol` attribute is defined, you can test a instance has the symbol like `FormCategory.find(1).checkbox?`.



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hiratai/active_value.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

