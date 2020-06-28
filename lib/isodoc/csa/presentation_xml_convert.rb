require_relative "init"
require "isodoc"

module IsoDoc
  module Csa
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      include Init
    end
  end
end

