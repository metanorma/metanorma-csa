require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Csa do
  it "Warns of illegal doctype" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :doctype: pizza

      text
    INPUT

    expect { Asciidoctor.convert(input, backend: :csa, header_footer: true) }
      .to output(/pizza is not a legal document type/).to_stderr
  end

  it "Warns of illegal status" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :no-isobib:
      :status: pizza

      text
    INPUT

    expect { Asciidoctor.convert(input, backend: :csa, header_footer: true) }
      .to output(/pizza is not a recognised status/).to_stderr
  end

end
