module Twostroke::AST
  class Function < Base
    attr_accessor :name, :arguments, :statements, :fnid
    
    def initialize(*args)
      @arguments = []
      @statements = []
      super *args
    end
    
    def collapse
      self.class.new name: name, arguments: arguments, statements: statements.reject(&:nil?).map(&:collapse), fnid: fnid
    end
    
    def walk(&bk)
      if yield self
        statements.each { |s| s.walk &bk }
      end
    end
  end
end