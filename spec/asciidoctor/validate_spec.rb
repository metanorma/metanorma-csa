# frozen_string_literal: true

require 'spec_helper'
RSpec.describe Asciidoctor::Csa do
  it 'Warns of illegal doctype' do
    Asciidoctor.convert(<<~"INPUT", backend: :csa, header_footer: true) 
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT
    expect(File.read("test.err")).to include "pizza is not a legal document type"

  end

  it 'Warns of illegal status' do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT

    Asciidoctor.convert(input, backend: :csa, header_footer: true) 
    expect(File.read("test.err")).to include "pizza is not a recognised status"
  end
end
