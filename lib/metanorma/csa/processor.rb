# frozen_string_literal: true

require 'metanorma/processor'
require 'asciidoctor/csa/converter'

module Metanorma
  module Csa
    def self.fonts_used
      {
        html: %w(AzoSans AzoSans-Light SourceCodePro-Light),
        doc: %w(AzoSans AzoSans-Light SourceCodePro-Light),
        pdf: %w(AzoSans AzoSans-Light SourceCodePro-Light)
      }
    end

    class Processor < Metanorma::Processor

      def initialize
        @short = :csa
        @input_format = :asciidoc
        @asciidoctor_backend = Asciidoctor::Csa::CSA_TYPE.to_sym
      end

      def output_formats
        super.merge(
          html: 'html',
          doc: 'doc',
          pdf: 'pdf'
        )
      end

      def version
        "Metanorma::Csa #{Metanorma::Csa::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Csa::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Csa::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Csa::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
