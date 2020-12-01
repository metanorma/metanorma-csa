# frozen_string_literal: true

require 'asciidoctor'
require 'metanorma-generic'
require 'isodoc/csa/html_convert'
require 'isodoc/csa/pdf_convert'
require 'isodoc/csa/word_convert'
require 'isodoc/csa/presentation_xml_convert'
require 'metanorma/csa'
require 'fileutils'

module Asciidoctor
  module Csa
    class Converter < ::Asciidoctor::Generic::Converter
      XML_ROOT_TAG = "csa-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/csa".freeze

      register_for "csa"

      def configuration
        Metanorma::Csa.configuration
      end

      def personal_role(node, c, suffix)
        role = node.attr("role#{suffix}")&.downcase || "full author"
        c.role **{ type: role == "editor" ? "editor" : "author" } do |r|
          r.description role.strip.gsub(/\s/, "-")
        end
      end

      def metadata_committee(node, xml)
        return unless node.attr("technical-committee")
        xml.editorialgroup do |a|
          a.committee node.attr("technical-committee"),
            **attr_code(type: node.attr("technical-committee-type"))
          i = 2
          while node.attr("technical-committee_#{i}") do
            a.committee node.attr("technical-committee_#{i}"),
              **attr_code(type: node.attr("technical-committee-type_#{i}"))
            i += 1
          end
        end
      end

      def title_validate(root)
        nil
      end

      def outputs(node, ret)
        File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
          presentation_xml_converter(node).convert(@filename + ".xml")
          html_converter(node).convert(@filename + ".presentation.xml", 
                                       nil, false, "#{@filename}.html")
          doc_converter(node).convert(@filename + ".presentation.xml", 
                                      nil, false, "#{@filename}.doc")
          pdf_converter(node)&.convert(@filename + ".presentation.xml", 
                                       nil, false, "#{@filename}.pdf")
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete('inline-header')
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

      def style(n, t)
        return
      end

      def html_converter(node)
        IsoDoc::Csa::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        return if node.attr("no-pdf")
        IsoDoc::Csa::PdfConvert.new(html_extract_attributes(node))
      end

      def doc_converter(node)
        IsoDoc::Csa::WordConvert.new(doc_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Csa::PresentationXMLConvert.new(doc_extract_attributes(node))
      end
    end
  end
end
