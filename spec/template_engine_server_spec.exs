defmodule TemplateEngineServerSpec do
  use ESpec, async: true
  import TemplateEngine

  it "should start up, render and shut down" do
    {:ok, pid} = TemplateEngine.start_link

    TemplateEngine.render( pid, "{{{foo}}}", %{ "foo" => "bar" } )
    |> should( eq "\"bar\"" )

    TemplateEngine.stop( pid ) |> should( eq :ok )
  end
end

