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

      def ul_label_list(_elem)
        %w(&#x2022; &#x2d; &#x6f;)
      end

      def ol_label_template(_elem)
        super
          .merge({
                   alphabet_upper: %{%<span class="fmt-label-delim">)</span>},
                 })
      end

      include Init
    end
  end
end
