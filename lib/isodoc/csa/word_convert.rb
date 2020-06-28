# frozen_string_literal: true

require_relative 'base_convert'
require_relative 'init'
require 'isodoc'

module IsoDoc
  module Csa
    # A {Converter} implementation that generates CSA output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        is_hans = options[:script] == 'Hans'
        {
          bodyfont: (is_hans ? '"SimSun",serif' : 'AzoSans,Arial,sans-serif'),
          headerfont: (is_hans ? '"SimHei",sans-serif' : 'AzoSans,Arial,sans-serif'),
          monospacefont: '"Source Code Pro","Courier New",monospace'
        }
      end

      def default_file_locations(options)
        {
          wordstylesheet: html_doc_path('wordstyle.scss'),
          standardstylesheet: html_doc_path('csa.scss'),
          header: html_doc_path('header.html'),
          wordcoverpage: html_doc_path('word_csa_titlepage.html'),
          wordintropage: html_doc_path('word_csa_intro.html'),
          ulstyle: 'l3',
          olstyle: 'l2'
        }
      end

      include BaseConvert
      include Init
    end
  end
end
