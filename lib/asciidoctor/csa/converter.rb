require "asciidoctor"
require "metanorma/csa/version"
require "isodoc/csa/html_convert"
require "isodoc/csa/pdf_convert"
require "isodoc/csa/word_convert"
require "asciidoctor/standoc/converter"
require "fileutils"
require_relative "./validate.rb"

module Asciidoctor
  module Csa
    CSA_NAMESPACE = 'https://open.ribose.com/standards/csa'.freeze
    CSA_TYPE = 'csa'.freeze

    # A {Converter} implementation that generates CSD output, and a document
    # schema encapsulation of the document for validation
    class Converter < Standoc::Converter

      register_for CSA_TYPE

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name "Cloud Security Alliance"
          end
        end
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name "Cloud Security Alliance"
          end
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
        docstatus = node.attr("status")
        dn = node.attr("docnumber")
        if docstatus
          abbr = IsoDoc::Csa::Metadata.new("en", "Latn", {}).
            status_abbr(docstatus)
          dn = "#{dn}(#{abbr})" unless abbr.empty?
        end
        node.attr("copyright-year") and dn += ":#{node.attr("copyright-year")}"
        xml.docidentifier dn, **{ type: CSA_TYPE }
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name "Cloud Security Alliance"
            end
          end
        end
      end

      def title_validate(root)
        nil
      end

      def makexml(node)
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<csa-standard>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << '</csa-standard>'
        result = textcleanup(result)
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1) unless @novalid
        ret1.root.add_namespace(nil, CSA_NAMESPACE)
        ret1
      end

      def doctype(node)
        d = node.attr("doctype")
        unless %w{guidance proposal standard report whitepaper charter policy glossary case-study}.include? d
          warn "#{d} is not a legal document type: reverting to 'standard'"
          d = "standard"
        end
        d
      end

      def document(node)
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          html_converter(node).convert filename unless node.attr("nodoc")
          pdf_converter(node).convert filename unless node.attr("nodoc")
          word_converter(node).convert filename unless node.attr("nodoc")
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        File.join(File.dirname(__FILE__), 'csa.rng'))
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
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
      def word_converter(node)
        IsoDoc::Csa::WordConvert.new(doc_extract_attributes(node))
      end
    end
  end
end