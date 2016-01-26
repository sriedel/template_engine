defmodule TemplateEngineServerSpec do
  use ESpec, async: true
  import TemplateEngine

  it "should start up, render and shut down" do
    {:ok, pid} = start_link

    render( pid, "{{{foo}}}", %{ "foo" => "bar" } )
    |> should( eq "\"bar\"" )

    stop( pid ) |> should( eq :ok )
  end
end

