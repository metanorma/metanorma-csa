# frozen_string_literal: true

require 'asciidoctor'
require 'metanorma/csa/version'
require 'isodoc/csa/html_convert'
require 'isodoc/csa/pdf_convert'
require 'isodoc/csa/word_convert'
require 'isodoc/csa/presentation_xml_convert'
require 'asciidoctor/standoc/converter'
require 'fileutils'
require_relative 'validate'

module Asciidoctor
  module Csa
    CSA_TYPE = 'csa'

    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "csa-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/csa".freeze

      register_for CSA_TYPE

      def default_publisher
        "Cloud Security Alliance"
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

      def metadata_id(node, xml)
        dn = node.attr('docnumber') or return
        docstatus = node.attr('status')
        if docstatus
          abbr = IsoDoc::Csa::Metadata.new('en', 'Latn', @i18n)
            .stage_abbr(docstatus)
          dn = "#{dn}(#{abbr})" unless abbr.empty?
        end
        node.attr('copyright-year') && dn += ":#{node.attr('copyright-year')}"
        xml.docidentifier dn, **{ type: CSA_TYPE }
        xml.docnumber { |i| i << node.attr('docnumber') }
      end

      def title_validate(root)
        nil
      end

      def doctype(node)
        d = super
        unless %w{guidance proposal standard report whitepaper charter policy
          glossary case-study}.include? d
          @log.add("Document Attributes", nil,
                   "#{d} is not a legal document type: reverting to 'standard'")
          d = 'standard'
        end
        d
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

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), 'csa.rng'))
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete('inline-header')
        end
      end

      def style(n, t)
        return
      end

      def html_converter(node)
        IsoDoc::Csa::HtmlConvert.new(html_extract_attributes(node))
      end
      def pdf_converter(node)
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
