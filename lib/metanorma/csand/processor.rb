require "metanorma/processor"

module Metanorma
  module Csand
    class Processor < Metanorma::Processor

      def initialize
        @short = :csand
        @input_format = :asciidoc
        @asciidoctor_backend = :csand
      end

      def output_formats
        {
          html: "html"
        }
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Csand::HtmlConvert.new(options).convert(outname, isodoc_node)
        end
      end

    end
  end
end