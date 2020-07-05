require "isodoc"
require_relative "metadata"
require_relative "xref"

module IsoDoc
  module Csa
    module Init
      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def xref_init(lang, script, klass, labels, options)
        html = HtmlConvert.new(language: lang, script: script)
        @xrefs = Xref.new(lang, script, html, labels, options)
      end

      def i18n_init(lang, script)
        super
        @annex_lbl = "Appendix"
        @labels["annex"] = "Appendix"
      end
    end
  end
end

