require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Csand
    # A {Converter} implementation that generates CSAND output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Arial",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Arial",sans-serif'),
          monospacefont: '"Courier New",monospace'
        }
      end

      def default_file_locations(options)
        {
          wordstylesheet: html_doc_path("wordstyle.scss"),
          standardstylesheet: html_doc_path("csand.scss"),
          header: html_doc_path("header.html"),
          wordcoverpage: html_doc_path("word_csand_titlepage.html"),
          wordintropage: html_doc_path("word_csand_intro.html"),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      include BaseConvert
    end
  end
end

