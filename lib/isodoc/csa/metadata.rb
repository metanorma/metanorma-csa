# frozen_string_literal: true

require "isodoc"

module IsoDoc
  module Csa
    # A {Converter} implementation that generates CSA output, and a document
    # schema encapsulation of the document for validation
    class Metadata < IsoDoc::Generic::Metadata
      def configuration
        Metanorma::Csa.configuration
      end

      def title(isoxml, _out)
        main = isoxml.at(ns("//bibdata/title[@language='en']"))
          &.children&.to_xml
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

      def personal_authors(isoxml)
        persons = auth_roles(isoxml, nonauth_roles(isoxml, {}))
        set(:roles_authors_affiliations, persons)
        super
      end

      def nonauth_roles(isoxml, persons)
        roles = isoxml.xpath(ns("//bibdata/contributor[person]/role/@type"))
          .inject([]) { |m, t| m << t.value }.reject { |i| i == "author" }
        roles.uniq.sort.each do |r|
          n = isoxml.xpath(ns("//bibdata/contributor[role/@type = '#{r}']"\
                              "/person"))
          n.empty? or persons[r] = extract_person_names_affiliations(n)
        end
        persons
      end

      def auth_roles(isoxml, persons)
        roles = isoxml.xpath(ns("//bibdata/contributor[person]/"\
                                "role[@type = 'author']/description"))
          .inject([]) { |m, t| m << t.text }
        roles.uniq.sort.each do |r|
          n = isoxml.xpath(
            ns("//bibdata/contributor[role/@type = 'author']"\
               "[xmlns:role/description = '#{r}']/person"),
          )
          n.empty? or persons[r] = extract_person_names_affiliations(n)
        end
        persons
      end
    end
  end
end
