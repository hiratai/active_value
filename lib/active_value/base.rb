require "active_support/core_ext/hash/keys"
require "json"

module ActiveValue
  # ActiveValue::Base is base class for immutable value object that has interfaces like ActiveRecord.
  # In a class inherited this class, constant variables get the behavior like records of ActiveRecord.
  #
  # Usage.
  #   1. Define the target class inherited from ActiveValue::Base
  #   2. List attributes of the object using attr_accessor
  #   3. Declare constant variables as this class
  #
  # Example.
  #   class QuestionType < ActiveValue::Base
  #     attr_accessor :id, :symbol, :name
  #     CHECKBOX  = new id: 1, symbol: :checkbox, name: "Check Box"
  #     RADIO     = new id: 2, symbol: :radio,    name: "Radio Button"
  #     SELECTBOX = new id: 3, symbol: :select,   name: "Select Box"
  #     TEXT      = new id: 4, symbol: :text,     name: "Text Box"
  #     TEXTAREA  = new id: 5, symbol: :textarea, name: "Text Area"
  #   end
  #   QuestionType.find(1)
  #   => QuestionType::CHECKBOX
  #   QuestionType.find(1).name
  #   => "Check Box"
  #   QuestionType.find(1).checkbox?
  #   => true
  #   QuestionType.pluck(:id, :name)
  #   => [[1, "Check Box"], [2, "Radio Button"], [3, "Select Box"], ...]

  class Base

    # Delegate undefined method calls to `all` method (returns Array).
    # If objects have symbol attributes, the objects can be checked equivalence by the method named symbol + `?`
    def self.method_missing(method, *args, &block)
      object = unsorted_all.find { |object| object.respond_to?(:symbol) && method.to_s == object.public_send(:symbol).to_s + '?' }
      if object.nil?
        all.public_send(method, *args, &block)
      else
        self == object
      end
    end

    # Getter interface by the id element like `find` method in ActiveRecord.
    def self.find(index)
      object = all.bsearch { |object| object.public_send(:id) >= index }
      object&.id == index ? object : nil
    end

    # Getter interface by the argument element like `find_by` method in ActiveRecord.
    def self.find_by(conditions)
      unsorted_all.find do |object|
        conditions.all? { |key, value| object.public_send(key) == value }
      end
    end

    # Get all constant instances. (Unsorted)
    def self.unsorted_all
      constants.collect { |name| const_get(name) }.select { |object| object.instance_of?(self) }
    end

    # Get all constant instances. (Sorted by the first defined accessor)
    def self.all
      unsorted_all.sort
    end

    # Get attributes
    def self.pluck(*accessors)
      map { |record| Array(accessors).map { |accessor| record.public_send(accessor) } }.map { |array| array.size == 1 ? array.first : array }
    end

    # Automatically these methods are defined in this version. This method is remained only for compatibility.
    def self.define_question_methods(attr_name = :symbol)
      unsorted_all.each do |object|
        define_method(object.public_send(attr_name).to_s + '?') { self == object } if object.respond_to?(attr_name)
      end
    end

    # Wrap default attr_accessor method in order to save accessor defined order.
    def self.attr_accessor(*several_variants)
      @accessors = *several_variants
      super
    end

    # Get accessors the overrided method saved.
    def self.accessors
      readers = instance_methods.reject { |attr| attr.to_s[-1] == '=' }
      writers = instance_methods.select { |attr| attr.to_s[-1] == '=' }.map { |attr| attr.to_s.chop.to_sym }
      accessors = readers & writers - [:!]
      Array(@accessors) | accessors.reverse!
    end

    # If self instance is passed as an argument, create a new instance that has copied attributes. (it's like copy constructor by shallow copy)
    # Hash instance is passed, the hash attributes apply a new instance.
    def initialize(attributes = {})
      case attributes
      when self.class then self.class.accessors.map(&:to_s).each { |attribute| public_send(attribute + '=', attributes.public_send(attribute)) }
      when Hash       then attributes.stringify_keys.each { |key, value| public_send(key + '=', value) if respond_to?(key + '=') }
      end
    end

    # Convert to hash with shallow copy. If values include collections(Hash, Array, etc.), search and convert without elements of the collection.
    def to_shallow_hash
      self.class.accessors.each_with_object({}) { |key, hash| hash[key] = public_send(key).dup }
    end

    # Convert to hash with deep copy. If values include collections(Hash, Array, etc.), search and convert into collections recursively.
    def to_deep_hash
      scan = ->(value) do
        case value
        when Hash  then value.each_with_object({}) { |(k, v), h| h[k] = scan.call(v) }
        when Array then value.map { |v| scan.call(v) }
        when Base  then scan.call(value.to_shallow_hash)
        else value.dup
        end
      end
      self.class.accessors.each_with_object({}) { |key, hash| hash[key] = scan.call(public_send(key)) }
    end
    alias_method :to_h, :to_deep_hash

    def to_json
      JSON.generate(to_h)
    end

    def inspect
      hash = to_shallow_hash
      Hash === hash ? '#<' << self.class.name.split('::').last << ' ' << hash.map { |key, value| key.to_s << ': ' << value.inspect }.join(', ') << '>' : hash.inspect
    end

    # Define the equal operator. `A == B` expression means every attribute has same value. (NOT object_id comparison)
    def ==(another)
      self.class.accessors.all? { |attr| public_send(attr) == another.public_send(attr) }
    end
    alias_method :eql?, :==

    # Hash method for equivalence comparison with `eql?` method. (Referenced by `Enumerable#uniq` method etc.)
    def hash
      to_json.hash
    end

    # Define the spaceship operator. Compare self with another by the first defined accessor. (In many cases, it's `id` implicitly)
    def <=>(another)
      attr = self.class.accessors.first || :object_id
      public_send(attr) <=> another.public_send(attr) if respond_to?(attr) && another.respond_to?(attr)
    end

  end
end