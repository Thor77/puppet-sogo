Puppet::Functions.create_function(:plgen) do
  dispatch :plgen do
    param 'Hash', :input
  end

  def plgen(input)
    recursive_plgen(input)
  end

  def recursive_plgen(input, level = 1)
    indent = '  ' * level

    if input.is_a?(Array)
      nil
    end

    unless input.is_a?(Hash)
      indent + input.to_s + ",\n"
    end

    out = ''

    input.each do |key, value|
      out.concat(indent + key + ' = ')

      case value
      when Hash
        out.concat("{\n")
        out.concat(recursive_plgen(value, level + 1))
        out.concat(indent + "};\n")
      when Array
        out.concat("(\n")
        arr_element = 0
        value.each do |v|
          arr_element += 1
          if v.is_a?(Hash)
            out.concat(indent + "  {\n")
            out.concat(recursive_plgen(v, level + 2))
            if arr_element < value.length
              out.concat(indent + "  },\n")
            else
              out.concat(indent + "  }\n")
            end
          else
            out.concat(recursive_plgen(v, level + 2))
          end
        end

        out.concat(indent + ");\n")
      else
        out.concat(value.to_s + ";\n")
      end
    end
    out
  end
end
