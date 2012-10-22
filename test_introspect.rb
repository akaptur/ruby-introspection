class Test
  attr_reader :list_not_initialized

  def test
    a = 3
    b = 2
    a + b
  end

  def break_things
    @list_not_initialized << 1
  end
end

t = Test.new
t.test
# t.break_things exception handling

