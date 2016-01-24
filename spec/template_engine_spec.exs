defmodule TemplateEngineSpec do
  use ESpec, async: true
  import TemplateEngine

  describe "evaluate" do
    context "when passed an empty string as template" do
      it do: evaluate( "", %{} ) |> should( eq "" )
    end

    context "when passed a string without an interpolation" do
      context "and the string does not the \{ escape sequence" do
        it do: evaluate( "abc", %{} ) |> should( eq "abc" )
      end

      context "and the string contains the \{ escape sequence" do
        it do: evaluate( "a\\{b", %{} ) |> should( eq "a{b" )
      end
    end

    context "when passed a string with half an interpolation token" do
      context "and the string does not contain escaped {" do
        it do: evaluate( "a{{{b", %{} ) |> should( eq "a{{{b" )
      end

      context "and the string contains escaped {" do
        it do: evaluate( "a{{{b\\{\\{\\{", %{} ) |> should( eq "a{{{b{{{" )
      end
    end

    context "when passed a string with one interpolation" do
      context "and the string does not contain an escaped {" do
        context "and the value map does not contain a key for the value name" do
          it do: evaluate( "foo {{{bar}}} baz", %{} ) |> should( eq "foo  baz" )
        end

        context "and the value map contains a key for the value name" do
          context "for a string value" do
            it do: evaluate( "{{{val}}}", %{"val" => "ue"} ) |> should( eq "ue" )
          end

          context "for an integer value" do
            it do: evaluate( "{{{val}}}", %{"val" => 1 } ) |> should( eq "1" )
          end

          context "for a float value" do
            it do: evaluate( "{{{val}}}", %{"val" => 1.1 } ) |> should( eq "1.1" )
          end

          context "for a nil value" do
            it do: evaluate( "{{{val}}}", %{"val" => nil } ) |> should( eq "null" )
          end

          context "for a string value containing a \{ escape sequence" do
            it do: evaluate( "{{{val}}}", %{"val" => "\\{"} ) |> should( eq "\\{" )
          end
        end
      end

      context "and the string contains an escaped {" do
        context "and the value map does not contain a key for the value name" do
          it do: evaluate( "foo {{{bar}}} \\{\\{\\{baz}}}", %{} ) |> should( eq "foo  {{{baz}}}" )
        end

        context "and the value map contains a key for the value name" do
          context "for a string value" do
            it do: evaluate( "{{{val}}}\\{\\{\\{foo}}}", %{"val" => "ue"} ) |> should( eq "ue{{{foo}}}" )
          end

          context "for an integer value" do
            it do: evaluate( "{{{val}}}\\{\\{\\{foo}}}", %{"val" => 1 } ) |> should( eq "1{{{foo}}}" )
          end

          context "for a float value" do
            it do: evaluate( "{{{val}}}\\{\\{\\{foo}}}", %{"val" => 1.1 } ) |> should( eq "1.1{{{foo}}}" )
          end

          context "for a nil value" do
            it do: evaluate( "{{{val}}}\\{\\{\\{foo}}}", %{"val" => nil } ) |> should( eq "null{{{foo}}}" )
          end

          context "for a string value containing a \{ escape sequence" do
            it do: evaluate( "{{{val}}}\\{\\{\\{foo}}}", %{"val" => "\\{"} ) |> should( eq "\\{{{{foo}}}" )
          end
        end
      end
    end

    context "when passed a string with multiple interpolations" do
      it do: evaluate( "{{{integer}}} {{{string}}} \\{{{escaped}}} {{{float}}}",
                       %{ "integer" => 3, "string" => "hello", "float" => 3.14 } )
             |> should( eq "3 hello {{{escaped}}} 3.14" )
    end

    context "when matching a nested value" do
      let :map, do: %{ "top" => %{ "middle" => %{ "bottom" => "foo" } } }
      it do: evaluate( "{{{top.middle.bottom}}}", map ) |> should( eq "foo" )

      it do: evaluate( "{{{top.middle.i_dont_exist}}}", map ) |> should( eq "" )

      it do: evaluate( "{{{top.middle.bottom}}}", %{"top" => %{ "middle" => "foo" } } )
             |> should( eq "null" )
    end
  end

  describe "split_and_unescape" do
    it do: split_and_unescape( "" ) |> should( eq [] )
    it do: split_and_unescape( "foo" ) |> should( eq [ "foo" ] )
    it do: split_and_unescape( "foo.bar" ) |> should( eq [ "foo", "bar" ] )
    it do: split_and_unescape( "foo..bar" ) |> should( eq [ "foo", "", "bar" ] )
    it do: split_and_unescape( "foo\\.bar" ) |> should( eq [ "foo.bar" ] )
    it do: split_and_unescape( "foo.bar\\.baz.quux" ) |> should( eq [ "foo", "bar.baz", "quux" ] )
  end
end
