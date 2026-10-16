require "nokogiri"
require "metanorma-generic"

module Metanorma
  module Csa
    class Validate < Metanorma::Generic::Validate
      def bibdata_validate(doc)
        super
        role_validate(doc)
      end

      def role_validate(doc)
        doc&.xpath("//bibdata/contributor/role[description]")&.each do |r|
          r["type"] == "author" or next
          role = r.at("./description").text
          %w{full-author contributor staff reviewer}.include?(role) or
            @log.add("CSA_1", nil, params: [role])
        end
      end
    end
  end
end
