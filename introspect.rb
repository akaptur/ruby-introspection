require 'json'
input_file = "./#{ARGV[0]}.rb"

class Tracer
  attr_reader :code, :locals, :trace
  
  def initialize
    @line_nums_executed = []
    @trace = []
    @code = ""
  end

  def activate_trace
    trace_proc = Proc.new { |event, file, line_num, id, binding, classname|
      if file.include? ARGV[0]
        printf "%8s %s %s %10s %s %s\n", event, file, line_num, id, binding, classname
        subtrace = {}
        # subtrace["ordered_globals"] = []
        # subtrace["stdout"] = binding.eval("stdout.flush")
        subtrace["func_name"] = id
        # subtrace["stack_to_render"] = []
        # subtrace["globals"] = binding.eval("global_variables") # not quite what we need
        # subtrace["heap"] = []
        subtrace["line"] = line_num
        subtrace["event"] = event

        @trace << subtrace
      end
    }
    set_trace_func(trace_proc)
  end

  def stop_trace
    set_trace_func nil
  end

  def read_file(filename)
    file = File.open(filename)
    @code = file.read #returns a string
    file.close
  end

end

def generate_json(code, trace)
  {"code" => code, "trace" => trace}.to_json
end

tracer = Tracer.new
tracer.read_file(input_file)

tracer.activate_trace
load input_file #loads & executes input file code

tracer.stop_trace
print generate_json(tracer.code, tracer.trace)


