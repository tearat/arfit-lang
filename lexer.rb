require 'colorize'

class Lexer
    attr_accessor :quiet

    def initialize(code_array)
        @code_array = code_array
    end

    def log!
        @log = true
    end

    def mute!
        @log = false
    end

    def lex
        n = 0
        events = []
        @code_array.each do |line|
            n += 1
            line.gsub! "\n", ""
            line.strip!
            # if line != ""
            event = parse_line line
            # puts event[:event]
            if @log
                if event[:event] != "comment" && event[:event] != "blank"
                    puts ""
                    puts line.green
                    puts parse_line line
                end
            end

            # if event[:event] != "comment" && event[:event] != "blank"
                events.push event
            # end
        end
        return events
    end


    def is_int? value
        return value == value.to_i.to_s
    end


    def is_str? value
        return value != value.to_i.to_s
    end


    def var_type? value
        if value.is_a? Integer
            return "int"
        end
        if value.is_a? String
            return "string"
        end
        return "undefined"
    end


    def parse_line line
        rest = line
        options = {}
        options[:code] = line

        if line == ""
            options[:event] = "blank"
            return options
        end

        if line =~ /\/\/.+?/
            options[:event] = "comment"
            options[:value] = line.match(/\/\/(.+)/)[1].strip
            return options
        end

        if line =~ /(int|string)(.+)\S(.+?)=(.+?)(\S+)/
            options[:event] = "declaration"
            matches = line.match(/(int|string).+(\S).+?=.+?(\S+)/)
            options[:var_type] = matches[1]
            options[:var]      = matches[2]
            options[:value]    = matches[3]

            if options[:var_type] == "int"
                if !is_int?(options[:value])
                    options[:error] = true
                    options[:error_type] = "TypeError"
                    options[:error_message] = "Type error. Expected Integer"
                end
                options[:value] = options[:value].to_i
            end

            if options[:var_type] == "string"
                # TODO: catch wrong notation with double " etc
                if options[:value] =~ /\"(.+)\"/
                    matches = options[:value].match(/\"(.+)\"/)
                    options[:value] = matches[1]
                else
                    options[:error] = true
                    options[:error_type] = "TypeError"
                    options[:error_message] = "Type error. Wrong string format"
                end

                if self.var_type?(options[:value]) != "string"
                    options[:error] = true
                    options[:error_type] = "TypeError"
                    options[:error_message] = "Type error. Expected String"
                end
            end
            return options
        end

        if line =~ /\S(.+?)=(.+?)(\S+)/
            options[:event] = "setting"
            matches = line.match(/(\S).+?=.+?(\S+)/)
            options[:var] = matches[1]
            options[:value] = matches[2]

            if is_int? options[:value]
                options[:var_type] = "int"
            elsif is_str? options[:value]
                if options[:value] =~ /\"(.+)\"/
                    options[:var_type] = "string"
                    options[:value] = options[:value].match(/\"(.+)\"/)[1]
                end
            end
            return options
        end

        if line =~ /(\S+).+?\+\+/
            options[:event] = "increment"
            options[:var] = line.match(/(\S+).+?\+\+/)[1]
            # options[:var] = line.split("++")[0]
            return options
        end

        if line =~ /(\S+).+?\-\-/
            options[:event] = "decrement"
            options[:var] = line.match(/(\S+).+?\-\-/)[1]
            # options[:var] = line.split("--")[0]
            return options
        end

        if line =~ /(print).+\S+/
            options[:event] = "print"
            arg = line.split("print")[1].strip
            if arg =~ /\".+\"/
                options[:arg_type] = "string"
                options[:arg] = arg.match(/\"(.+)\"/)[1]
            else
                options[:arg_type] = "var"
                options[:arg] = arg.strip
            end
            return options
        end

        options[:event] = "blank"
        return options
    end
end
