# frozen_string_literal: true
require "fileutils"

require 'spec_helper'
RSpec.describe Metanorma::Csa do
  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        mock_pdf
        Metanorma::Compile
          .new
          .compile("spec/assets/xref_error.adoc", type: "csa", :"agree-to-terms" => true)
      end.to(change { File.exist?("spec/assets/xref_error.err") }
              .from(false).to(true))
    end
  end

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
