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

      def fonts_manifest
        {
          #"AzoSans" => nil,
          "Lato" => nil,
          "STIX Two Math" => nil,
          "Source Code Pro" => nil,
          "Noto Sans" => nil,
          "Noto Sans HK" => nil,
          "Noto Sans JP" => nil,
          "Noto Sans KR" => nil,
          "Noto Sans SC" => nil,
          "Noto Sans TC" => nil,
          "Noto Sans Mono" => nil,
          "Noto Sans Mono CJK HK" => nil,
          "Noto Sans Mono CJK JP" => nil,
          "Noto Sans Mono CJK KR" => nil,
          "Noto Sans Mono CJK SC" => nil,
          "Noto Sans Mono CJK TC" => nil,
        }
      end

      def version
        "Metanorma::Csa #{Metanorma::Csa::VERSION}"
      end

      def output(isodoc_node, inname, outname, format, options={})
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
