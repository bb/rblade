require_relative "statements/compiles_conditionals"

class CompilesStatements

  def self.compile!(tokens)
    tokens.each do |token|
      if token.type != :statement
        next
      end

      name = token.value[:name]
      arguments = token.value[:arguments]
      handler = @@statementHandlers[name]

      if handler.nil?
        raise Exception.new "Unhandled statement: @#{name}"
      end

      token.value = handler.call(arguments)
    end
  end

  def self.compileEnd statement
    return "end;"
  end
  @@statementHandlers = {
    "if" => CompilesConditionals.method(:compileIf),
    "endif" => CompilesStatements.method(:compileEnd),
    "end" => CompilesStatements.method(:compileEnd)
  }
end
