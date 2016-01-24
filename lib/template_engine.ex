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
    dig( map, split_and_unescape( value_name, "", [] ) )
  end

  def split_and_unescape( string ), do: split_and_unescape( string, "", [] )
  defp split_and_unescape( "", "", acc ), do: Enum.reverse( acc )
  defp split_and_unescape( "", current_value, acc ) do
    split_and_unescape( "", "", [ String.reverse( current_value ) | acc ] )
  end
  defp split_and_unescape( <<"\\.", string::binary>>, current_value, acc ) do
    split_and_unescape( string, "." <> current_value, acc )
  end
  defp split_and_unescape( <<".", string::binary>>, current_value, acc ) do
    split_and_unescape( string, "", [ String.reverse( current_value ) | acc ] )
  end
  defp split_and_unescape( <<char::utf8, string::binary>>, current_value, acc ) do
    split_and_unescape( string, <<char::utf8, current_value::binary>>, acc )
  end


  defp dig( map, [] ), do: to_string( map )
  defp dig( map, _value_name_list = [h|t] ) when is_map( map ) do
    case Map.fetch( map, h ) do
      { :ok, nil } -> "null"
      { :ok, val } -> dig( val, t )
      :error -> "null"
    end
  end
  defp dig( map, _value_name_list = [h|t] ) when is_list( map ) do
    case Enum.fetch( map, String.to_integer( h ) ) do
      { :ok, nil } -> "null"
      { :ok, val } -> dig( val, t )
      :error -> "null"
    end
  end
  defp dig( _map, _value_name_list ), do: "null"

end
