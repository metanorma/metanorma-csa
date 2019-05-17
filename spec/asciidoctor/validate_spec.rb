require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Csand do
it "Warns of illegal status" do
    expect { Asciidoctor.convert(<<~"INPUT", backend: :csand, header_footer: true) }.to output(/pizza is not a recognised status/).to_stderr
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :no-isobib:
  :status: pizza

  text
  INPUT
end

end
