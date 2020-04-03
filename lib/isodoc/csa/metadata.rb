# frozen_string_literal: true

require 'isodoc'

module IsoDoc
  module Csa
    # A {Converter} implementation that generates CSA output, and a document
    # schema encapsulation of the document for validation
    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//bibdata/title[@language='en']"))&.text
        set(:doctitle, main)
      end

      def subtitle(_isoxml, _out)
        nil
      end

      def author(isoxml, _out)
        set(:tc, "XXXX")
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
        super
      end


      def docid(isoxml, _out)
        docnumber = isoxml.at(ns("//bibdata/docidentifier[@type = 'csa']"))
        set(:docnumber, docnumber&.text)
      end

      def stage_abbr(status)
        case status
        when "working-draft" then "wd"
        when "committee-draft" then "cd"
        when "draft-standard" then "d"
        else
          ""
        end
      end

      def unpublished(status)
        !%w(published withdrawn).include? status.downcase
      end
    end
  end
end
