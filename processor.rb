require 'colorize'

class Processor
    def initialize(events)
        @events = events
        @completed_events = []
        @vars = {}
    end

    def raise_error type, messages, n, code
        puts ""
        puts "Arfit processor raises an exception: #{type}".red
        messages.each do |message|
            puts "> #{message}".red
        end
        puts ""
        puts "line #{n}: #{code}"
        puts ""
    end

    def var_type? var
        if var.is_a? Integer
            return "int"
        end
        if var.is_a? String
            return "string"
        end
        return "undefined"
    end

    # def can_set_value_to_variable? value, variable
    #     puts self.var_type?(value)
    #     puts variable[:var_type]
    #     return self.var_type?(value) == variable[:var_type]
    # end


    def find_last_declaration var
        @completed_events.each do |event|
            if event[:event] == "declaration" && event[:var] == var
                return event
            end
        end
    end


    def run
        n = 0
        @events.each do |event|
            n += 1
            event[:line] = n
            # p event
            if event[:error]
                self.raise_error event[:error_type], [event[:error_message]], n, event[:code]
                return
            end

            if event[:event] == "declaration"
                if @vars.has_key? event[:var]
                    declaration_event = find_last_declaration(event[:var])
                    self.raise_error "DeclarationError::declaration", [
                        "Variable already declared at line #{declaration_event[:line]}:",
                        "#{declaration_event[:code]}"
                        ], n, event[:code]
                    return
                end
                new_var = {
                    :var_type => event[:var_type],
                    :value => event[:value],
                }
                var_name = event[:var]
                @vars[var_name] = new_var
            end

            if event[:event] == "setting"
                if event[:var_type] != @vars[event[:var]][:var_type]
                    self.raise_error "SettingError::setting", ["Variable type is not correct"], n, event[:code]
                    return
                else
                    if event[:var_type] == "string"
                        @vars[event[:var]][:value] = event[:value]
                    else
                        @vars[event[:var]][:value] = event[:value].to_i
                    end
                end
            end

            if event[:event] == "increment"
                if !@vars.has_key? event[:var]
                    self.raise_error "SettingError::increment", ["Variable not declared"], n, event[:code]
                    return
                end
                if @vars[event[:var]][:var_type] != "int"
                    self.raise_error "SettingError::increment", ["Variable type is not Integer"], n, event[:code]
                    return
                end
                @vars[event[:var]][:value] += 1
            end

            if event[:event] == "decrement"
                if !@vars.has_key? event[:var]
                    self.raise_error "SettingError::decrement", ["Variable not declared"], n, event[:code]
                    return
                end
                if @vars[event[:var]][:var_type] != "int"
                    self.raise_error "SettingError::decrement", ["Variable type is not Integer"], n, event[:code]
                    return
                end
                @vars[event[:var]][:value] -= 1
            end

            if event[:event] == "print"
                if event[:arg_type] == "string"
                    puts event[:arg]
                end
                if event[:arg_type] == "var"
                    if !@vars.has_key? event[:arg]
                        self.raise_error "OutputError::print", ["Variable not declared"], n, event[:code]
                        return
                    else
                        puts @vars[event[:arg]][:value]
                    end
                end
            end
            # p @vars
            # puts ""
            @completed_events.push event
            # p @completed_events
        end
    end
end
