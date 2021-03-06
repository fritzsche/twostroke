module Twostroke::Runtime
  Lib.register do |scope|
    obj = Types::Object.new
    scope.set_var "Math", obj
    
    scope.set_var "Infinity", Types::Number.new(Float::INFINITY)
    scope.set_var "NaN", Types::Number.new(Float::NAN)
    
    scope.set_var "isNaN", Types::Function.new(->(scope, this, args) {
      Types::Boolean.new(args[0].is_a?(Types::Number) && args[0].nan?)
    }, nil, "isNaN", [])
    
    scope.set_var "parseInt", Types::Function.new(->(scope, this, args) {
      str = Types.to_string(args[0] || Undefined.new).string.gsub(/\A\s+/,"")
      unless args[1] and (radix = Types.to_uint32(args[1])) != 0
        case str
        when /\A0x/i; radix = 16
        when /\A0/i;  radix = 8
        else;         radix = 10
        end
      end
      if radix < 2 or radix > 36
        Types::Number.new(Float::NAN)
      else
        begin
          Integer(str[0], radix) # ensure the first character can be converted
          Types::Number.new str.to_i radix
        rescue
          Types::Number.new(Float::NAN)
        end
      end
    }, nil, "parseInt", [])
    
    # one argument functions
    %w(sqrt sin cos tan).each do |method|
      obj.proto_put method, Types::Function.new(->(scope, this, args) {
          ans = begin
                  Math.send method, Types.to_number(args[0] || Undefined.new).number
                rescue Math::DomainError
                  Float::NAN
                end
          Types::Number.new(ans)
        }, nil, method, [])
    end

    obj.proto_put "PI", Types::Number.new(Math::PI)

    obj.proto_put "random", Types::Function.new(->(scope, this, args) {
      Types::Number.new rand
    }, nil, "random", [])

    obj.proto_put "floor", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.floor
      }, nil, "floor", [])

    obj.proto_put "ceil", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.ceil
      }, nil, "ceil", [])
      
    obj.proto_put "abs", Types::Function.new(->(scope, this, args) {
        Types::Number.new Types.to_number(args[0] || Undefined.new).number.abs
      }, nil, "floor", [])
    
    obj.proto_put "max", Types::Function.new(->(scope, this, args) {
        Types::Number.new [-Float::INFINITY, *args.map { |a| Types.to_number(a).number }].max
      }, nil, "max", [])
    
    obj.proto_put "min", Types::Function.new(->(scope, this, args) {
        Types::Number.new [Float::INFINITY, *args.map { |a| Types.to_number(a).number }].min
      }, nil, "min", [])
      
    obj.proto_put "pow", Types::Function.new(->(scope, this, args) {
        a = Types.to_number(args[0] || Types::Undefined.new).number
        b = Types.to_number(args[1] || Types::Undefined.new).number
        ans = a ** b
        Types::Number.new(ans.is_a?(Complex) ? Float::NAN : ans)
      }, nil, "random", [])
  end
end