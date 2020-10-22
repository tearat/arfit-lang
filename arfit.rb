require 'colorize'
require 'dotenv/load'
require 'optparse'
require 'yaml'

require_relative "lexer"
require_relative "processor"


options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: parser.rb [options]"
    opts.on("-h", "--help", "Показать это сообщение") { puts opts }
    opts.on("-d", "--debug", "Debug mode") { options[:debug] = true }
end.parse!

filename = ARGV[0]

code = File.open filename
code_array = []
code.each do |line|
    code_array.push line
end

lexer = Lexer.new code_array
if options.has_key? :debug
    lexer.log!
end
events = lexer.lex

processor = Processor.new events
processor.run
