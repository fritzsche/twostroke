module Twostroke::Runtime
  class Scope
    attr_reader :parent
    
    def initialize(parent = nil)
      @locals = {}
      @parent = parent
    end
    
    def get_var(var)
      if @locals.has_key? var
        @locals[var]
      else
        @parent.get_var(var)
      end
    end
    
    def set_var(var, value)
      if @locals.has_key? var
        @locals[var] = value
      else
        @parent.set_var(var, value)
      end
    end
    
    def has_var(var)
      @locals.has_key?(var) || parent.has_var(var)
    end
    
    def declare(var)
      @locals[var] = Types::Undefined.new
    end
    
    def delete(var)
      if has_var var
        @locals.delete var
      else
        parent.delete var
      end
    end
    
    def close
      Scope.new self
    end
    
    def global_scope
      @global_scope ||= parent.global_scope
    end
  end
  
  class ObjectScope
    attr_reader :object, :parent
    
    def initialize(object, parent)
      @parent, @object = parent, object
    end
    
    def get_var(var)
      if object.has_property var.to_s
        object.get var.to_s
      else
        parent.get_var var
      end
    end
    
    def set_var(var, value)
      if object.has_property var.to_s
        object.put var.to_s, value
      else
        parent.set_var var, value
      end
    end
    
    def has_var(var)
      object.has_property(var.to_s) || parent.has_var(var)
    end
    
    def declare(var)
      parent.declare var
    end
    
    def delete(var)
      if has_var var
        object.delete var.to_s
      else
        parent.delete var
      end
    end
    
    def close
      Scope.new self
    end
    
    def global_scope
      @global_scope ||= parent.global_scope
    end
  end
  
  class GlobalScope
    attr_reader :root_object, :root_name, :vm
    
    def initialize(vm, root_name = "window", root_object = nil)
      @root_name = root_name
      @root_object = root_object || Types::Object.new
      @root_object.put root_name.to_s, @root_object
      @vm = vm
    end
    
    def get_var(var)
      if @root_object.has_property var.to_s
        @root_object.get var.to_s
      else
        Lib.throw_reference_error "undefined variable #{var}"
      end
    end
    
    def has_var(var)
      @root_object.has_property var.to_s
    end
    
    def declare(var)
      @root_object.put var.to_s, Types::Undefined.new
    end
    
    def delete(var)
      @root_object.delete var.to_s
    end
    
    def close
      Scope.new self
    end
    
    def set_var(var, value)
      @root_object.put var.to_s, value
    end
    
    def global_scope
      self
    end
  end
end