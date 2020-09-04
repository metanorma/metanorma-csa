module Asciidoctor
  module Csa
    class Converter < Standoc::Converter
      def content_validate(doc)
        super
        bibdata_validate(doc.root)
      end

      def bibdata_validate(doc)
        stage_validate(doc)
        role_validate(doc)
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(proposal working-draft committee-draft draft-standard final-draft
        published withdrawn).include? stage or
        @log.add("Document Attributes", nil,
                 "#{stage} is not a recognised status")
      end

      def role_validate(doc)
        doc&.xpath("//bibdata/contributor/role[description]")&.each do |r|
          r["type"] == "author" or next
          role = r.at("./description").text
          %w{full-author contributor staff reviewer}.include?(role) or
        @log.add("Document Attributes", nil,
                 "#{role} is not a recognised role")
        end
      end
    end
  end
end
