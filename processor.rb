require 'colorize'

class Processor
    def initialize(events)
        @events = events
        @vars = {}
    end

    def raise_error type, message, n, line
        puts ""
        puts "Arfit processor raises an exception: #{type}".red
        puts "Message: #{message}".red
        puts "At line #{n}:".red
        puts ""
        puts "#{line}"
        puts ""
    end


    def is_int? var_name
        return @vars[var_name][:value] == @vars[var_name][:value].to_i.to_s.to_i
    end


    def is_str? var_name
        return @vars[var_name][:value] != @vars[var_name][:value].to_i.to_s
    end


    def run
        n = 0
        @events.each do |event|
            n += 1
            if event[:error]
                self.raise_error event[:error_type], event[:error_message], n, event[:line]
                return
            end

            if event[:event] == "declaration"
                new_var = {
                    :var_type => event[:var_type],
                    :value => event[:value],
                }
                var_name = event[:var]
                @vars[var_name] = new_var
            end

            if event[:event] == "increment"
                if !@vars.has_key? event[:var]
                    self.raise_error "VariableError", "Variable not declared", n, event[:line]
                    return
                end
                if !self.is_int? event[:var]
                    self.raise_error "VariableError", "Variable type is not Integer", n, event[:line]
                    return
                end
                @vars[event[:var]][:value] += 1
            end

            if event[:event] == "print"
                if event[:arg_type] == "string"
                    puts event[:arg]
                end
                if event[:arg_type] == "var"
                    if !@vars.has_key? event[:arg]
                        self.raise_error "VariableError", "Variable not declared", n, event[:line]
                        return
                    else
                        puts @vars[event[:arg]][:value]
                    end
                end
            end
            # p @vars
        end
    end
end
