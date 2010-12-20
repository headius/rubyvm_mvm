require 'jruby/vm'

# A partial implementation of Shyouhei's modified MVM API atop JRuby's
# implementation of Rubinius's MVM API.
# See:
# https://github.com/shyouhei/ruby/tree/shyouhei/mvm-topicalization
# https://github.com/jruby/jruby/blob/master/lib/ruby/site_ruby/shared/jruby/vm.rb

class RubyVM
  def initialize(*args)
    raise ArgumentError, "already initialized VM" if defined? @vm

    if args.length > 0 && args[0].kind_of?(JRuby::VM)
      @vm = args[0]
    else
      @vm = JRuby::ChildVM.new(args)
    end
  end
  
  attr_accessor :vm
  
  def to_s
    super
  end
  
  def start
    if defined? @vm.start
      @vm.start
    else
      raise RuntimeError, "JRuby 1.5 and earlier start VM on construction"
    end
  end
  
  def send(arg)
    @vm.send arg
  end
  
  def recv
    JRuby::VM::get_message
  end
  
  def join
    @vm.join
  end
  
  def parent
    raise NotImplementedError
  end
  
  # not in Shyouhei's API
  def stdout
    @vm.stdout
  end
  
  def stdin
    @vm.stdin
  end
  
  def stderr
    @vm.stderr
  end
  
  class << self
    def current
      RubyVM::CURRENT
    end
  
    def self.parent
      raise NotImplementedError
    end
  end
    
	CURRENT = RubyVM.new(JRuby::CURRENT)
end

class RubyVM::Wormhole
  def initialize
    raise NotImplementedError
  end
  
  def initialize_copy
    raise NotImplementedError
  end
  
  def send
    raise NotImplementedError
  end
  
  def recv
    raise NotImplementedError
  end
end

if __FILE__ == $0
  # sample usage
  vm_script = "
require 'rubyvm_mvm'
x = RubyVM.current.recv
puts x
"

  vm = RubyVM.new('-v', '-e', vm_script)
  vm.start
  vm.send 'hello'
  vm.join
  p vm.stdout.read
end