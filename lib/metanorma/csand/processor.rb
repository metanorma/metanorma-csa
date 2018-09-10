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
        super.merge(
          html: "html"
        )
      end

      def version
        "Metanorma::Csand #{Metanorma::Csand::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Csand::HtmlConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
