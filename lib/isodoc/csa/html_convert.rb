# frozen_string_literal: true

require_relative 'base_convert'
require 'isodoc'

module IsoDoc
  module Csa
    # A {Converter} implementation that generates CSA output, and a document
    # schema encapsulation of the document for validation
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        is_hans = options[:script] == 'Hans'
        {
          bodyfont: (is_hans ? '"SimSun",serif' : 'AzoSans,"Source Sans Pro",sans-serif'),
          headerfont: (is_hans ? '"SimHei",sans-serif'
                              : 'AzoSans,"Source Sans Pro",sans-serif'),
          monospacefont: '"Source Code Pro",monospace'
        }
      end

      def default_file_locations(options)
        {
          htmlstylesheet: html_doc_path('htmlstyle.scss'),
          htmlcoverpage: html_doc_path('html_csa_titlepage.html'),
          htmlintropage: html_doc_path('html_csa_intro.html'),
          scripts: html_doc_path('scripts.html')
        }
      end

      def googlefonts()
        <<~HEAD.freeze
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i|Space+Mono:400,700" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Rubik:300,300i,500" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,300i,400,700,900" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Source+Code+Pro:ital,wght@0,300;0,600;1,300;1,600&display=swap" rel="stylesheet">
        HEAD
      end

      def make_body(xml, docxml)
        body_attr = { lang: 'EN-US', link: 'blue', vlink: '#954F72',
                      'xml:lang': 'EN-US', class: 'container' }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      include BaseConvert
    end
  end
end

