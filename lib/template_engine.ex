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
    dig( map, expand_value_name( value_name ) )
  end

  defp expand_value_name( value_name ) do
    String.split( value_name, "." )
  end

  defp dig( map, [] ), do: to_string( map )

  defp dig( map, _value_name_list = [h|t] ) when is_map( map ) do
    case Map.fetch( map, h ) do
      { :ok, nil } -> "null"
      { :ok, val } -> dig( val, t )
      :error -> ""
    end
  end

  defp dig( map, _value_name_list = [h|t] ) when is_list( map ) do
    case Enum.fetch( map, String.to_integer( h ) ) do
      { :ok, nil } -> "null"
      { :ok, val } -> dig( val, t )
      :error -> "" #FIXME: Make this undefined
    end
  end

  defp dig( _map, _value_name_list ), do: "null" #FIXME: undefined?

end
