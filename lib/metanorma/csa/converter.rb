# frozen_string_literal: true

require "asciidoctor"
require "metanorma-generic"
require "isodoc/csa/html_convert"
require "isodoc/csa/pdf_convert"
require "isodoc/csa/word_convert"
require "isodoc/csa/presentation_xml_convert"
require "metanorma/csa"
require "fileutils"

module Metanorma
  module Csa
    class Converter < ::Metanorma::Generic::Converter
      XML_ROOT_TAG = "csa-standard"
      XML_NAMESPACE = "https://www.metanorma.org/ns/csa"

      register_for "csa"

      def configuration
        Metanorma::Csa.configuration
      end

      def personal_role(node, contrib, suffix)
        role = node.attr("role#{suffix}")&.downcase || "full author"
        contrib.role **{ type: role == "editor" ? "editor" : "author" } do |r|
          r.description role.strip.gsub(/\s/, "-")
        end
      end

      def title_validate(_root)
        nil
      end

      def outputs(node, ret)
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node).convert("#{@filename}.xml")
        html_converter(node).convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.html")
        doc_converter(node).convert("#{@filename}.presentation.xml",
                                    nil, false, "#{@filename}.doc")
        pdf_converter(node)&.convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.pdf")
      end

      def sections_cleanup(xml)
        super
        xml.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def bibdata_validate(doc)
        super
        role_validate(doc)
      end

      def role_validate(doc)
        doc&.xpath("//bibdata/contributor/role[description]")&.each do |r|
          r["type"] == "author" or next
          role = r.at("./description").text
          %w{full-author contributor staff reviewer}.include?(role) or
            @log.add("Document Attributes", nil,
                     "#{role} is not a recognised role")
        end
      end

      def style(_node, _text)
        nil
      end

      def html_converter(node)
        IsoDoc::Csa::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")

        IsoDoc::Csa::PdfConvert.new(pdf_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Csa::WordConvert.new(doc_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Csa::PresentationXMLConvert
          .new(doc_extract_attributes(node)
          .merge(output_formats: ::Metanorma::Csa::Processor.new.output_formats))
      end
    end
  end
end
