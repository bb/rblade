class CompilesConditionals
  def self.compileIf args
    if args&.count != 1
      raise Exception.new "If statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});"
  end

  def self.compileUnless args
    if args&.count != 1
      raise Exception.new "Unless statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "unless(#{args[0]});"
  end

  def self.compileChecked args
    if args&.count != 1
      raise Exception.new "Checked statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});_out<<'checked';end;"
  end

  def self.compileDisabled args
    if args&.count != 1
      raise Exception.new "Disabled statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});_out<<'disabled';end;"
  end

  def self.compileReadonly args
    if args&.count != 1
      raise Exception.new "Readonly statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});_out<<'readonly';end;"
  end

  def self.compileRequired args
    if args&.count != 1
      raise Exception.new "Required statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});_out<<'required';end;"
  end

  def self.compileSelected args
    if args&.count != 1
      raise Exception.new "Selected statement: wrong number of arguments (given #{args&.count || 0}, expecting 1)"
    end

    return "if(#{args[0]});_out<<'selected';end;"
  end
end
