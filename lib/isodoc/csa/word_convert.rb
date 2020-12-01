# frozen_string_literal: true

require_relative 'base_convert'
require "isodoc/generic/word_convert"
require_relative 'init'
require 'isodoc'

module IsoDoc
  module Csa
    # A {Converter} implementation that generates CSA output, and a document
    # schema encapsulation of the document for validation
    class WordConvert < IsoDoc::WordConvert

      include BaseConvert
      include Init
    end
  end
end
