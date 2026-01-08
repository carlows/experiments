module Regex
  class Parser
    CONCAT_CHAR = '.'

    def self.insert_explicit_concat(tokens)
      output = []

      tokens.each_with_index do |token, i|
        output << token

        next if i == tokens.length - 1

        next_token = tokens[i + 1]

        token_ends_expression = !['(', '|'].include?(token)
        next_token_starts_expression = ![')', '|', '*', '+', '?'].include?(next_token)

        output << CONCAT_CHAR if token_ends_expression && next_token_starts_expression
      end

      output
    end

    def self.to_tokens(pattern)
      tokens = []

      curr = 0
      while curr < pattern.size
        case pattern[curr]
        when '\\'
          next_token = pattern[curr + 1]

          tokens << if next_token.nil?
                      pattern[curr]
                    else
                      pattern[curr] + next_token
                    end

          curr += 2
        else
          tokens << pattern[curr]
          curr += 1
        end
      end

      tokens
    end

    def self.to_postfix(tokens)
      expanded_pattern = insert_explicit_concat(tokens)

      output_queue = []
      operator_stack = []

      precedence = { '*' => 3, '+' => 3, '?' => 3, '.' => 2, '|' => 1 }

      expanded_pattern.each do |token|
        if token == '('
          operator_stack.push(token)
        elsif token == ')'
          output_queue << operator_stack.pop while operator_stack.any? && operator_stack.last != '('
          operator_stack.pop
        elsif precedence.key?(token)
          while operator_stack.any? &&
                operator_stack.last != '(' &&
                precedence[operator_stack.last] >= precedence[token]
            output_queue << operator_stack.pop
          end
          operator_stack.push(token)
        else
          output_queue << token
        end
      end

      output_queue << operator_stack.pop while operator_stack.any?

      output_queue
    end
  end

  class State
    attr_accessor :label, :out1, :out2

    def initialize(label = nil, out1 = nil, out2 = nil)
      @label = label
      @out1 = out1
      @out2 = out2
    end
  end

  class Fragment
    attr_accessor :start_state, :end_states

    def initialize(start_state, end_states)
      @start_state = start_state
      @end_states = end_states
    end

    def patch(state)
      @end_states.each do |s|
        if s.out1.nil?
          s.out1 = state
        else
          s.out2 = state
        end
      end
    end
  end

  class Compiler
    def self.compile(tokens)
      stack = []

      tokens.each do |token|
        case token
        when '.'
          frag2 = stack.pop
          frag1 = stack.pop

          frag1.patch(frag2.start_state)

          stack.push(Fragment.new(frag1.start_state, frag2.end_states))
        when '|'
          frag2 = stack.pop
          frag1 = stack.pop

          start = State.new(nil, frag1.start_state, frag2.start_state)

          stack.push(Fragment.new(start, frag1.end_states + frag2.end_states))
        when '*'
          frag = stack.pop

          start = State.new(nil, frag.start_state, nil)

          frag.patch(start)

          stack.push(Fragment.new(start, [start]))
        when '+'
          frag = stack.pop

          loop_state = State.new(nil, frag.start_state, nil)

          frag.patch(loop_state)

          stack.push(Fragment.new(frag.start_state, [loop_state]))
        when '?'
          frag = stack.pop

          start = State.new(nil, frag.start_state, nil)

          stack.push(Fragment.new(start, frag.end_states + [start]))
        else
          s = State.new(token)
          stack.push(Fragment.new(s, [s]))
        end
      end

      return nil if stack.empty?

      final_fragment = stack.pop
      match_state = State.new
      final_fragment.patch(match_state)

      final_fragment.start_state
    end
  end

  class Matcher
    def initialize(pattern, options = {})
      tokens = Parser.to_tokens(pattern)
      postfix = Parser.to_postfix(tokens)
      @start_state = Compiler.compile(postfix)
      @ignore_case = options[:ignore_case] || false
    end

    def match?(text)
      current_states = add_next_state(@start_state, [], is_start: true, is_end: text.empty?)

      text.chars.each_with_index do |char, index|
        next_states = []

        return true if success?(current_states)

        current_states.each do |state|
          next unless literal_match?(state, char)

          is_end = (index + 1) == text.length
          add_next_state(state.out1, next_states, is_start: false, is_end: is_end)
        end

        add_next_state(@start_state, next_states, is_start: false, is_end: (index + 1) == text.length)

        current_states = next_states
      end

      success?(current_states)
    end

    private

    def literal_match?(state, char)
      char_with_case = @ignore_case ? char.downcase : char
      digits = %w[0 1 2 3 4 5 6 7 8 9]
      return true if state.label == '\d' && digits.include?(char)
      return true if state.label == '\w' && ('a'..'z').include?(char_with_case)

      state.label == char_with_case
    end

    def success?(current_states)
      current_states.any? { |s| s.label.nil? && s.out1.nil? && s.out2.nil? }
    end

    def add_next_state(state, state_list, is_start:, is_end:)
      return state_list if state.nil? || state_list.include?(state)

      if state.label == '^'
        add_next_state(state.out1, state_list, is_start: is_start, is_end: is_end) if is_start
        return state_list
      end

      if state.label == '$'
        add_next_state(state.out1, state_list, is_start: is_start, is_end: is_end) if is_end
        return state_list
      end

      if state.label.nil? && !(state.out1.nil? && state.out2.nil?)
        add_next_state(state.out1, state_list, is_start: is_start, is_end: is_end)
        add_next_state(state.out2, state_list, is_start: is_start, is_end: is_end)
      else
        state_list << state
      end

      state_list
    end
  end
end
