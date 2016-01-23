defmodule TemplateEngine do
  def evaluate( string, map ) do
    Regex.replace( ~r/(?:\\{|{{{(.*?)}}})/, 
                   string, 
                   fn match, value_name -> 
                     evaluate_match( match, value_name, map ) 
                   end )
  end

  defp evaluate_match( "\\{", _value_name, _map ), do: "{"
  defp evaluate_match( <<"{{{"::utf8, _something::binary>>, value_name, map ) do
    extract_value_of( value_name, map )
  end

  defp extract_value_of( value_name, map ) when is_map( map ) do
    case String.split( value_name, ".", parts: 2 ) do
      [ key ] -> 
        if not Map.has_key?( map, key ) do
          ""
        else
          if map[value_name] == nil do
            "null"
          else
            map[value_name] |> to_string
          end
        end

      [ key, child_keys ] ->
        if not Map.has_key?( map, key ) do
          ""
        else
          extract_value_of( child_keys, map[key] )
        end
    end
  end
  defp extract_value_of( _value_name, _map ), do: "null"

end
