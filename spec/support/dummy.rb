# frozen_string_literal: true

# Test class to simulate an ActiveRecord class.
class Dummy
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def page(_number)
    self
  end

  def per(_number)
    self
  end

  def try(_anything)
    nil
  end

  def model
    self.class
  end
end

# Test serializer for Foo class
class DummySerializer
  def initialize(*_args); end
end
