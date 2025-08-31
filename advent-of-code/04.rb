class XMas
  def count_xmas(input)
    @count = 0

    board = convert_to_board(input)

    height = board.size
    width = board[0].size

    (0...height).each do |i|
      (0...width).each do |y|
        next if board[i][y] != 'X'

        count_from_x(i, y, board)
      end
    end

    @count
  end

  private

  def count_from_x(i, y, board)
    directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ]

    directions.each do |di, dy|
      next_i = i + di
      next_y = y + dy
      curr_word = 'X'
      target_word = 'XMAS'

      while inbound?(next_i, next_y, board) && target_word.start_with?(curr_word + board[next_i][next_y])
        curr_word << board[next_i][next_y]

        if target_word == curr_word
          @count += 1
          break
        end
        next_i += di
        next_y += dy
      end
    end
  end

  def inbound?(i, y, board)
    height = board.size
    width = board[0].size

    # check for the horizontal boundaries
    return false if i < 0 || i >= height
    # check for the vertical boundaries
    return false if y < 0 || y >= width

    true
  end

  def convert_to_board(input)
    lines = input.split("\n")
    lines.map { |line| line.split('') }
  end
end

require_relative './assert.rb'
extend SuperDuperAssertions

subject = XMas.new
assert('Forwards', subject.count_xmas('XMAS'), 1)
assert('Backwards', subject.count_xmas('SAMX'), 1)

triple_xmas = <<~TEXT
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
TEXT

assert('advent of code example', subject.count_xmas(triple_xmas), 18)

real_input = File.read('./input04.txt')

puts "The answer should be: #{subject.count_xmas(real_input)}"
