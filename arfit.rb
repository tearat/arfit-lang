require 'colorize'
require 'dotenv/load'
require 'optparse'
require 'yaml'

require_relative "lexer"
require_relative "processor"


# cities = YAML.load(File.read("cities.yml"))

# options = {}
# OptionParser.new do |opts|
#     opts.banner = "Usage: parser.rb [options]"
#     opts.on("-h", "--help", "Показать это сообщение") { puts opts }
#     opts.on("-ls", "--list", "--cities", "Показать все доступные города") { options[:list] = true }
#     opts.on("-c CITY", "--city=CITY", "Город для поиска (по умолчанию: spb, Санкт-Петербург)") { |city| options[:city] = city }
#     opts.on("-t TEXT", "--text=TEXT", "Текст для поискового запроса") { |text| options[:text] = text }
#     opts.on("-p PAGE", "--page=PAGE", "Страница (по умолчанию: 1)") { |page| options[:page] = page }
#     opts.on("-a", "--all", "Парсить все города по всем запросам") { options[:all] = true }
# end.parse!

filename = ARGV[0]

code = File.open filename
code_array = []
code.each do |line|
    code_array.push line
end

lexer = Lexer.new code_array
lexer.log!
events = lexer.lex

processor = Processor.new events
processor.run
