require 'sass/script'
require 'sass/script/css_lexer'

module Sass
  module Script
    # This is a subclass of {Parser} for use in parsing plain CSS properties.
    #
    # @see Sass::SCSS::CssParser
    class CssParser < Parser
      private

      # @private
      def lexer_class; CssLexer; end

      # We need a production that only does /,
      # since * and % aren't allowed in plain CSS
      production :div, :unary_plus, :div

      def string
        tok = try_tok(:string)
        return number unless tok
        return if @lexer.peek && @lexer.peek.type == :begin_interpolation
        literal_node(tok.value, tok.source_range)
      end

      def ident
        return funcall unless @lexer.peek && @lexer.peek.type == :ident
        return if @stop_at && @stop_at.include?(@lexer.peek.value)

        name = @lexer.next
        if (color = Sass::Script::Value::Color::COLOR_NAMES[name.value.downcase])
          literal_node(Sass::Script::Value::Color.new(color, name.value), name.source_range)
        else
          literal_node(Sass::Script::Value::String.new(name.value, :identifier), name.source_range)
        end
      end

      # Short-circuit all the SassScript-only productions
      def interpolation(first: nil, inner: :space)
        first || send(inner)
      end

      alias_method :or_expr, :div
      alias_method :unary_div, :ident
      alias_method :paren, :string
    end
  end
end
