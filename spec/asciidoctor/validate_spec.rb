# frozen_string_literal: true
require "fileutils"

require 'spec_helper'
RSpec.describe Asciidoctor::Csa do
  it 'Warns of illegal doctype' do
    FileUtils.rm_rf "test.err"
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

    FileUtils.rm_rf "test.err"
    Asciidoctor.convert(input, backend: :csa, header_footer: true) 
    expect(File.read("test.err")).to include "pizza is not a recognised status"
  end

  it 'Warns of illegal role' do
    FileUtils.rm_rf "test.err"
    Asciidoctor.convert(<<~"INPUT", backend: :csa, header_footer: true)
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza
      :fullname: Fred Flintstone
      :role: Pokemon Man

      text
    INPUT
    expect(File.read("test.err")).to include "pokemon-man is not a recognised role"

  end

end
