require 'benchmark'
require 'rubygems'
require 'nokogiri'

class Parser < Nokogiri::XML::SAX::Document
  attr_reader :response

  def initialize
    reset
  end

  def reset
    @item = {}
    @response = { :items => [] }
  end

  def characters(string)
    @value ||= ''
    @value << string.strip
  end

  def start_element(name, attrs = [])
    @value = nil
  end

  def end_element(name)
    case name
    when 'item'
      @response[:items] << @item
      @item = {}
    when 'key'
      @item[:key] = value
    end
  end

  def value
    @value.dup
  end
end

data = <<-DATA
<items>
  <item>
    <key>value</key>
  </item>
</items>
DATA

COUNT = 10_000

Benchmark.bmbm(25) do |bench|
  bench.report('parse') do
    COUNT.times do
      parser = Parser.new
      Nokogiri::XML::SAX::Parser.new(parser).parse(data)
      parser.response
    end
  end

  bench.report('push') do
    COUNT.times do
      parser = Parser.new
      Nokogiri::XML::SAX::PushParser.new(parser).write(data, true)
      parser.response
    end
  end
end
