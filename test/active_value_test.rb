require 'test_helper'

class ActiveValueTest < Minitest::Test

  class TestRank < ActiveValue::Base
    attr_accessor :id, :symbol, :name
    GOLD   = new id: 1, symbol: :gold,   name: "Gold"
    SILVER = new id: 2, symbol: :silver, name: "Silver"
    BRONZE = new id: 3, symbol: :bronze, name: "Bronze"
  end

  class TestNest < ActiveValue::Base
    attr_accessor :id, :array, :hash, :test_rank
    ONE = new id: 1, array: ["a", "b", "c"], hash: { a: 1, b: 2, c: 3 }, test_rank: TestRank::GOLD
  end

  def test_that_it_has_a_version_number
    refute_nil ::ActiveValue::VERSION
  end

  def test_find
    assert_equal TestRank::GOLD, TestRank.find(1)
    assert_nil TestRank.find(0)
    assert_nil TestRank.find(10)
  end

  def test_find_by
    assert_equal TestRank::GOLD, TestRank.find_by(name: "Gold")
    assert_nil TestRank.find_by(name: "Wood")
  end

  def test_unsorted_all
    objects = TestRank.unsorted_all
    assert_instance_of Array, objects
    assert_equal [TestRank], objects.map(&:class).uniq
    assert_equal 3, objects.size
  end

  def test_all
    objects = TestRank.all
    assert_equal [1, 2, 3], objects.map(&:id)
  end

  def test_pluck
    assert_equal [:gold, :silver, :bronze], TestRank.pluck(:symbol)
    assert_equal [[1, "Gold"], [2, "Silver"], [3, "Bronze"]], TestRank.pluck(:id, :name)
  end

  def test_accessors
    assert_equal [:id, :symbol, :name], TestRank.accessors
  end

  def test_initialize
    hash_init = TestRank.new(id: 4, symbol: :platinum, name: "Platinum")
    copy_init = TestRank.new(hash_init)
    assert_instance_of TestRank, hash_init
    assert_equal [4, :platinum, "Platinum"], [hash_init.id, hash_init.symbol, hash_init.name]
    assert_instance_of TestRank, copy_init
    assert_equal [4, :platinum, "Platinum"], [copy_init.id, copy_init.symbol, copy_init.name]
    assert_equal hash_init, copy_init
  end

  def test_to_shallow_hash
    hash = TestRank.find(1).to_shallow_hash
    answer = { id: 1, symbol: :gold, name: "Gold" }
    assert_equal answer, hash
  end

  def test_to_deep_hash
    hash = TestNest.find(1).to_deep_hash
    answer = { id: 1, array: ["a", "b", "c"], hash: { a: 1, b: 2, c: 3 }, test_rank: { id: 1, symbol: :gold, name: "Gold" } }
    assert_equal answer, hash
    hash[:array][0] << "a"
    assert_equal answer, TestNest.find(1).to_deep_hash
  end

  def test_to_json
    json = TestNest.find(1).to_json
    assert_equal '{"id":1,"array":["a","b","c"],"hash":{"a":1,"b":2,"c":3},"test_rank":{"id":1,"symbol":"gold","name":"Gold"}}', json
  end

  def test_inspect
    text = TestRank.find(1).inspect
    assert_equal '#<TestRank id: 1, symbol: :gold, name: "Gold">', text
  end

  def test_equal_operator
    assert_operator TestRank::GOLD, :==, TestRank.find(1)
    assert_operator TestRank::GOLD, :==, TestRank.new(id: 1, symbol: :gold,   name: "Gold")
    assert_operator TestRank::GOLD, :!=, TestRank::SILVER
  end

  def test_spaceship_operator
    assert_equal TestRank::GOLD <=> TestRank::SILVER, -1
    assert_equal TestRank::SILVER <=> TestRank::GOLD, 1
    assert_equal TestRank::GOLD <=> TestRank::GOLD, 0
    assert_nil TestRank::GOLD <=> 1, 0
  end


end
