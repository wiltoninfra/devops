require 'json'

module Puppet::Pops
module Serialization

require_relative 'time_factory'
require_relative 'abstract_reader'
require_relative 'abstract_writer'

module JSON
  # A Writer that writes output in JSON format
  # @api private
  class Writer < AbstractWriter
    def initialize(io, options = {})
      super(Packer.new(io, options), options)
    end

    # Clear the underlying io stream but does not clear tabulation cache
    # Specifically designed to enable tabulation to span more than one
    # separately deserialized object.
    def clear_io
      @packer.clear_io
    end

    def extension_packer
      @packer
    end

    def packer
      @packer
    end

    def build_payload
      yield(@packer)
    end

    def to_a
      @packer.to_a
    end

    def to_json
      @packer.to_json
    end
  end

  # A Reader that reads JSON formatted input
  # @api private
  class Reader < AbstractReader
    def initialize(io)
      super(Unpacker.new(io))
    end

    def re_initialize(io)
      @unpacker.re_initialize(io)
    end

    def read_payload(data)
      yield(@unpacker)
    end
  end

  # The JSON Packer. Modeled after the MessagePack::Packer
  # @api private
  class Packer
    def initialize(io, options = {})
      @io = io
      @io << '['
      @type_registry = {}
      @nested = []
      @verbose = options[:verbose]
      @verbose = false if @verbose.nil?
      @indent = options[:indent] || 0
    end

    def register_type(type, klass, &block)
      @type_registry[klass] = [type, klass, block]
    end

    def clear_io
      # Truncate everything except leading '['
      if @io.is_a?(String)
        @io.slice!(1..-1)
      else
        @io.truncate(1)
      end
    end

    def empty?
      @io.is_a?(String) ? io.length == 1 : @io.pos == 1
    end

    def flush
      # Drop last comma unless just start marker present
      if @io.is_a?(String)
        @io.chop! unless @io.length == 1
        @io << ']'
      else
        pos = @io.pos
        @io.pos = pos - 1 unless pos == 1
        @io << ']'
        @io.flush
      end
    end

    def write(obj)
      case obj
      when Array
        write_array_header(obj.size)
        obj.each { |x| write(x) }
      when Hash
        write_map_header(obj.size)
        obj.each_pair {|k, v| write(k); write(v) }
      when nil
        write_nil
      else
        write_scalar(obj)
      end
    end
    alias pack write

    def write_array_header(n)
      if n < 1
        @io << '[]'
      else
        @io << '['
        @nested <<  [false, n]
      end
    end

    def write_map_header(n)
      if n < 1
        @io << '{}'
      else
        @io << '{'
        @nested <<  [true, n * 2]
      end
    end

    def write_nil
      @io << 'null'
      write_delim
    end

    def to_s
      to_json
    end

    def to_a
      ::JSON.parse(io_string)
    end

    def to_json
      if @indent > 0
        ::JSON.pretty_unparse(to_a, { :indent => ' ' * @indent })
      else
        io_string
      end
    end

    # Write a payload object. Not subject to extensions
    def write_pl(obj)
      @io << obj.to_json << ','
    end

    def io_string
      if @io.is_a?(String)
        @io
      else
        @io.pos = 0
        @io.read
      end
    end
    private :io_string

    def write_delim
      nesting = @nested.last
      cnt = nesting.nil? ? nil : nesting[1]
      case cnt
      when 1
        @io << (nesting[0] ? '}' : ']')
        @nested.pop
        write_delim
      when Integer
        if (cnt % 2) == 0 || !nesting[0]
          @io << ','
        else
          @io << ':'
        end
        nesting[1] = cnt - 1
      else
        @io << ','
      end
    end
    private :write_delim

    def write_scalar(obj)
      ext = @type_registry[obj.class]
      if ext.nil?
        case obj
        when Numeric, String, true, false, nil
          @io << obj.to_json
          write_delim
        else
          raise SerializationError, "Unable to serialize a #{obj.class.name}"
        end
      else
        write_extension(ext, obj)
      end
    end
    private :write_scalar

    def write_extension(ext, obj)
      @io << '[' << extension_indicator(ext).to_json << ','
      @nested << nil
      write_extension_payload(ext, obj)
      @nested.pop
      if obj.is_a?(Extension::SequenceStart) && obj.sequence_size > 0
        @nested << [false, obj.sequence_size]
      else
        if @io.is_a?(String)
          @io.chop!
        else
          @io.pos -= 1
        end
        @io << ']'
        write_delim
      end
    end
    private :write_extension

    def write_extension_payload(ext, obj)
      ext[2].call(obj)
    end
    private :write_extension_payload

    def extension_indicator(ext)
      @verbose ? ext[1].name.sub(/^Puppet::Pops::Serialization::\w+::(.+)$/, '\1') : ext[0]
    end
    private :extension_indicator
  end

  class Unpacker
    def initialize(io)
      re_initialize(io)
      @type_registry = {}
      @nested = []
    end

    def re_initialize(io)
      parsed = parse_io(io)
      raise SerializationError, "JSON stream is not an array. It is a #{io.class.name}" unless parsed.is_a?(Array)
      @etor_stack = [parsed.each]
    end

    def read
      obj = nil
      loop do
        raise SerializationError, 'Unexpected end of input' if @etor_stack.empty?
        etor = @etor_stack.last
        begin
          obj = etor.next
          break
        rescue StopIteration
          @etor_stack.pop
        end
      end
      if obj.is_a?(Array)
        ext_etor = obj.each
        @etor_stack << ext_etor
        ext_no = ext_etor.next
        ext_block = @type_registry[ext_no]
        raise SerializationError, "Invalid input. #{ext_no} is not a valid extension number" if ext_block.nil?
        obj = ext_block.call(nil)
      end
      obj
    end

    def register_type(extension_number, &block)
      @type_registry[extension_number] = block
    end

    private

    def parse_io(io)
      case io
      when IO, StringIO
        ::JSON.parse(io.read)
      when String
        ::JSON.parse(io)
      else
        io
      end
    end
  end
end
end
end
