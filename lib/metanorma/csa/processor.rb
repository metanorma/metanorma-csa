# frozen_string_literal: true

require 'metanorma/processor'

module Metanorma
  module Csa
    class Processor < Metanorma::Processor

      def initialize
        @short = :csa
        @input_format = :asciidoc
        @asciidoctor_backend = :csa
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

      def output(isodoc_node, inname, outname, format, options={})
        options_preprocess(options)
        case format
        when :html
          IsoDoc::Csa::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Csa::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Csa::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Csa::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
