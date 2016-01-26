defmodule TemplateEngine do
  use GenServer
 
  # client interface
  def start_link( opts \\ [] ) do
    GenServer.start_link( __MODULE__, :ok, opts )
  end

  def render( server, template, map ) do
    GenServer.call( server, { :render, template, map } )
  end

  def stop( server ), do: GenServer.stop( server )

  # server callbacks
  def init( :ok ), do: { :ok, nil }

  def handle_call( {:render, template, map}, from, state ) do
    reply = evaluate( template, map ) 
    { :reply, reply, state }
  end

  # functionality
  def evaluate( string, map ) do
    evaluate( string, map, "" )
  end

  defp evaluate( "", _map, output ), do: output |> String.reverse
  defp evaluate( <<"\\{"::utf8, string::binary>>, map, output ) do
    evaluate( string, map, <<"{"::utf8, output::binary>> )
  end
  defp evaluate( <<"{{{"::utf8, string::binary>>, map, output ) do
    evaluate( string, map, output, "" ) 
  end
  defp evaluate( <<char::utf8, string::binary>>, map, output ) do
    evaluate( string, map, <<char::utf8, output::binary>> )
  end
  defp evaluate( "", _map, output, value_name ) do
    String.reverse( output ) <> "{{{" <> String.reverse( value_name )
  end
  defp evaluate( <<"\\{"::utf8, string::binary>>, map, output, value_name ) do
    evaluate( string, map, output, "{" <> value_name )
  end
  defp evaluate( <<"}}}"::utf8, string::binary>>, map, output, value_name ) do
    value_path = value_name 
                 |> String.reverse
                 |> split_and_unescape( "", [] )
    value = dig( map, value_path )
            |> represent
    evaluate( string, map, String.reverse( value ) <> output )
  end
  defp evaluate( <<char::utf8, string::binary>>, map, output, value_name ) do
    evaluate( string, map, output, <<char::utf8, value_name::binary>> )
  end


  defp represent( value ) when is_binary( value ), do: ~s("#{value}")
  defp represent( value ) when is_nil( value ), do: "null"
  defp represent( value ), do: to_string( value )

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


  defp dig( map, [] ), do: map
  defp dig( map, _value_name_list = [h|t] ) when is_map( map ) do
    case Map.fetch( map, h ) do
      { :ok, nil } -> nil
      { :ok, val } -> dig( val, t )
      :error -> nil
    end
  end
  defp dig( map, _value_name_list = [h|t] ) when is_list( map ) do
    case Enum.fetch( map, String.to_integer( h ) ) do
      { :ok, nil } -> nil
      { :ok, val } -> dig( val, t )
      :error -> nil
    end
  end
  defp dig( _map, _value_name_list ), do: nil

end
