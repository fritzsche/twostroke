module Twostroke::AST
  class Throw < Base
    attr_accessor :expression
    
    def collapse
      self.class.new expression: expression.collapse
    end
    
    def walk(&bk)
      if yield self
        expression.walk &bk
      end
    end
  end
end
