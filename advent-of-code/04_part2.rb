class XMas
  def count_xmas(input)
    @count = 0

    board = convert_to_board(input)

    height = board.size
    width = board[0].size

    (0...height - 2).each do |i|
      (0...width - 2).each do |y|
        next unless %w[S M].include?(board[i][y])

        count_x(i, y, board)
      end
    end

    @count
  end

  private

  def count_x(i, y, board)
    valid_words = %w[MAS SAM]

    first_diagonal = board[i][y] + board[i + 1][y + 1] + board[i + 2][y + 2]
    second_diagonal = board[i + 2][y] + board[i + 1][y + 1] + board[i][y + 2]

    @count += 1 if valid_words.include?(first_diagonal) && valid_words.include?(second_diagonal)
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

triple_xmas = <<~TEXT
.M.S......
..A..MSMS.
.M.S.MAA..
..A.ASMSM.
.M.S.M....
..........
S.S.S.S.S.
.A.A.A.A..
M.M.M.M.M.
..........
TEXT

assert('advent of code example', subject.count_xmas(triple_xmas), 9)

real_input = File.read('./input04.txt')

puts "The answer should be: #{subject.count_xmas(real_input)}"

