# require 'pry'

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

class Tracer
  attr_reader :line_nums_executed, :lines_read, :lines_not_executed, :locals
  
  def initialize
    @line_nums_executed = []
    @locals = [] #failing to initialize sends @locals << binding.eval("local_variables") into an infinite loop
  end

  def trace
    trace_proc = Proc.new { |event, file, line_num, id, binding, classname|
      printf "%8s %s %s %10s %s %s\n", event, file, line_num, id, binding, classname
      @locals << binding.eval("local_variables")
      if event == 'line' || event == 'call'
        @line_nums_executed << line_num
      end
    }
    set_trace_func(trace_proc)
  end

  def untrace
    set_trace_func nil
  end

  def read_file(file)
    @lines_read = file.readlines
  end

  def lines_not_executed
    @lines_not_executed ||= @lines_read.reject.with_index do |line, num|
      line == "\n" or @line_nums_executed.include? num #must use "or" not "||" to bind more loosely than fn application
    end
  end

end

tracer = Tracer.new
tracer.read_file(File.open(__FILE__)) #__FILE__ is current file
tracer.trace

t = Test.new
t.test
# t.break_things exception handling

tracer.untrace

puts "Local variables"
puts tracer.locals

puts "Lines executed"
tracer.line_nums_executed.each do |line_num|
  print line_num, ":", tracer.lines_read[line_num-1]
end
puts "Lines not executed"
tracer.lines_not_executed.each do |line|
  puts line
end

# binding.pry
