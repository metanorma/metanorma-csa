require_relative "init"
require "metanorma-generic"
require "isodoc"

module IsoDoc
  module Csa
    class PresentationXMLConvert < IsoDoc::Generic::PresentationXMLConvert
      def annex_delim(_elem)
        "<br/>"
      end

      def middle_title(docxml); end

      include Init
    end
  end
end
