require 'test_helper'
require 'minitest/byebug'

class CrosswordTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Crossword::VERSION
  end

  def test_optimal_solution_is_found_for_small_board
    words = {
      cat: 'A cat',
      try: 'to attempt to do something'
    }
    puzzle = Crossword::Puzzle.new(words)
    assert_equal 3, puzzle.board.width
    assert_equal 3, puzzle.board.height
    assert_equal 5, puzzle.board.number_of_squares
  end

  def test_return_nil_when_no_solution_found
    words = {
      cat: 'A cat',
      boy: 'A boy'
    }
    puzzle = Crossword::Puzzle.new(words)
    assert_nil puzzle.board
  end

  def test_find_intersections
    # <Crossword::Board:0x007fb5bf1fb6d0 @words=[#<Crossword::Board::Word:0x007fb5bf1fa8e8 @value=:cat, @x=0, @y=0, @direction="down">], @rightmost_point=0, @highest_point=0, @leftmost_point=0, @lowest_point=-3>
    board = Crossword::Board.new.place_word('cat', 0, 0, 'across')
    intersections = board.send('find_intersections', 'try')
    assert_equal [{x: 2, y: 0, direction: 'down'}], intersections
  end
end
