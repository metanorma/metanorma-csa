require_relative "base_convert"
require "isodoc"
require "metanorma-generic"

module IsoDoc
  module Csa
    class PdfConvert < IsoDoc::Generic::PdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      include BaseConvert
      include Init
    end
  end
end
