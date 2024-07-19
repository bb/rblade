require "ripper"

class TokenizesComponents
  def tokenize!(tokens)
    tokens.map! do |token|
      next(token) if token.type != :unprocessed

      segments = tokenizeComponentOpeningTags token.value

      i = 0
      while i < segments.count
        if segments[i] == "</" && segments[i + 1]&.match(/x[-:]/)
          segments[i] = Token.new(type: :component_end, value: {name: segments[i+1][2..-1]})

          segments.delete_at i + 1
          i += 1
        elsif segments[i] == '<' && segments[i + 1]&.match(/x[-:]/)
          name = segments[i+1][2..-1]
          rawAttributes = segments[i + 2] != '>' ? tokenizeAttributes(segments[i + 2]) : nil

          attributes = processAttributes rawAttributes

          if rawAttributes.nil?
            segments.delete_at i + 1
          else
            while segments[i + 1] != ">" && segments[i + 1] != "/>"
              segments.delete_at i + 1
            end
          end

          token_type = segments[i + 1] == "/>" ? :component : :component_start
          segments[i] = Token.new(type: token_type, value: {name:, attributes:})
          segments.delete_at i + 1

          i += 1
        elsif !segments[i].nil? && segments[i] != ""
          segments[i] = Token.new(type: :unprocessed, value: segments[i])

          i += 1
        else
          segments.delete_at i
        end
      end

      segments
    end.flatten!
  end

  private

  def processAttributes rawAttributes
    attributes = []
    i = 0
    while i < rawAttributes.count
      name = rawAttributes[i]
      if name == "@class" || name == "@style"
        attributes.push({type: name[1..-1], value: rawAttributes[i + 1][1..-2]})
        i += 2
      elsif name[0..1] == '{{'
        attributes.push({type: 'attributes', value: rawAttributes[i + 1][2..-2]})
        i += 1
      else
        attribute = {name:}

        if rawAttributes[i + 1] == '='
          attribute[:value] = rawAttributes[i + 2]
          i += 3
        else
          i += 1
        end

        # The "::" at the start of attributes is used to escape attribute names beginning with ":"
        if name[0..1] == "::"
          attribute[:type] = "string"
          attribute[:name].delete_prefix! ":"
          attributes.push(attribute)
          next
        end

        if name[0] == ":"
          attribute[:type] = attribute[:value].nil? ? "pass_through" : "ruby"
          attribute[:name].delete_prefix! ":"
          attributes.push(attribute)
          next
        end

        if attribute[:value].nil?
          attribute[:type] = "empty";
        else
          attribute[:type] = "string";
        end
        attributes.push(attribute)
      end
    end

    attributes
  end

  def tokenizeComponentOpeningTags value
    value.split(%r/
      # Opening and self-closing tags
      (?:
        (<)
          \s*
          (x[-\:][\w\-\:\.]*)
          ((?:
            \s+
            (?:
              (?:
                @class(\( (?: (?>[^()]+) | \g<-1> )* \))
              )
              |
              (?:
                @style(\( (?: (?>[^()]+)| \g<-1> )* \))
              )
              |
              (
                \{\{\s*attributes(?:[^}]+?)?\s*\}\}
              )
              |
              (?:
                [\w\-:.@%]+
                (?:
                  =
                  (?:
                    "[^"]*"
                    |
                    '[^\']*'
                    |
                    [^'"=<>\s]+
                  )
                )?
              )
            )
          )*)
          \s*
          (?<![=\-])
        (\/?>)
      )
      |
      # Closing tags
      (?:
        (<\/)
          \s*
          (x[-\:][\w\-\:\.]*)
          \s*
        >
      )
    /x)
  end

  def tokenizeAttributes segment
    segment.scan(%r/
      (?<=\s|^)
      (?:
        (?:
          (@class)(\( (?: (?>[^()]+) | \g<-1> )* \))
        )
        |
        (?:
          (@style)(\( (?: (?>[^()]+)| \g<-1> )* \))
        )
        |
        (?:
          (\{\{)\s*attributes([^}]+?)?\s*(\}\})
        )
        |
        (?:
          ([\w\-:.@%]+)
          (?:
            (=)
            (?:
              "([^"]*)"
              |
              '([^\']*)'
              |
              ([^'"=<>\s]+)
            )
          )?
        )
      )
      (?=\s|$)
    /x).flatten.compact
  end
end
