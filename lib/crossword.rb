require "crossword/version"
require 'pqueue'
require 'set'

module Crossword
  class Puzzle
    attr_accessor :board
    def initialize(words)
      @board = generate_branch_and_bound(words)
    end

    private
      def generate_branch_and_bound(words)
        best_solution_so_far = Float::INFINITY
        best_board = nil
        initial_board_possibilities = words.map { |word, clue| [Board.new.place_word(word, 0, 0, 'across'), down_board = Board.new.place_word(word, 0, 0, 'down')]}.flatten.map{|board| BoardWrapper.new(board, words.keys)}
        possible_boards = PQueue.new(initial_board_possibilities) { |a,b| a.minimum_projected_board_size < b.minimum_projected_board_size }
        until possible_boards.empty? do
          current_board = possible_boards.pop
          if current_board.complete?
            if (num_squares = current_board.number_of_squares) < best_solution_so_far
              best_solution_so_far = num_squares
              best_board = current_board
            end
          elsif current_board.number_of_squares < best_solution_so_far
            current_board.generate_possible_sub_boards.select{|board| board.minimum_projected_board_size < best_solution_so_far }.each do |board|
              possible_boards << board
            end
          end
        end
        return best_board
      end
  end

  class BoardWrapper
    def initialize(board, all_words)
      @board = board
      @unplaced_words = Set.new(all_words) - Set.new(board.locations.map{|w| w[:word]})
      @all_words = all_words
    end

    def generate_possible_sub_boards
      @unplaced_words.each_with_object([]) do |word, generated_boards|
        locations_for_word = @board.find_possible_locations(word)
        locations_for_word.each do |location|
          generated_boards << BoardWrapper.new(@board.clone.place_word(word, location[:x], location[:y], location[:direction]), @all_words)
        end
      end
    end

    def minimum_projected_board_size
      @board.minimum_projected_board_size(@unplaced_words)
    end

    def complete?
      @unplaced_words.empty?
    end

    def place_word(*args)
      @unplaced_words.delete args[0]
      @board.place_word(*args)
    end

    def clone
      BoardWrapper.new(board.clone, all_words)
    end

    def method_missing(method, *args)
      if @board.respond_to?(method)
        @board.send(method, *args)
      else
        super
      end
    end
  end


  class Board
    def initialize(words = [])
      @words = words
      @rightmost_point = @words.empty? ? -Float::INFINITY : @words.map(&:rightmost_point).max
      @highest_point = @words.empty? ? -Float::INFINITY : @words.map(&:highest_point).max
      @leftmost_point = @words.empty? ? Float::INFINITY : @words.map(&:leftmost_point).min
      @lowest_point = @words.empty? ? Float::INFINITY : @words.map(&:lowest_point).min
    end

    def width
      @rightmost_point - @leftmost_point + 1
    end

    def height
      @highest_point - @lowest_point + 1
    end

    def number_of_squares
      # check each word for intersections with others
      intersections = 0
      @words.each_with_index do |word, start_index|
        (start_index+1...words.count).each do |index|
          intersections += 1 if word.intersects?(@words[index])
        end
      end
      @words.map(&:value).map(&:length).reduce(&:+) - intersections
    end

    def place_word(word, x_index, y_index, direction)
      word = Word.new word, x_index, y_index, direction
      @words << word
      @highest_point = word.highest_point if word.highest_point > @highest_point
      @leftmost_point = word.leftmost_point if word.leftmost_point < @leftmost_point
      @lowest_point = word.lowest_point if word.lowest_point < @lowest_point
      @rightmost_point = word.rightmost_point if word.rightmost_point > @rightmost_point
      self
    end

    def get_words
      @words
    end

    def words
      @words.map(&:value)
    end

    def locations
      @words.map{|word| {word: word.value, x: word.x, y: word.y, direction: word.direction}}
    end

    def find_possible_locations(word)
      eliminate_bad_locations(word, find_intersections(word))
    end

    def minimum_projected_board_size(words_to_add)
      number_of_squares + (words_to_add.map(&:length).reduce(&:+) || 0)/2
    end

    def clone
      Board.new(@words.clone)
    end

    private
      def find_intersections(word)
        letters = Set.new(word.to_s.chars)
        intersecting_indices = []
        @words.each do |board_word|
          board_word.value.to_s.chars.each_with_index do |letter, index|
            if letters.include?(letter)
              indices_within_word = word.to_s.chars.each_with_index.map{|word_letter, word_index| [word_letter, word_index]}.select{|array| array[0] == letter}.map{|a| a[1]}
              intersection_index = board_word.coordinates_at_index(index)
              # and now we need to find what the word starting indices and direction would be for each possible intersection
              indices_within_word.each do |word_index|
                starting_x_index = board_word.across? ? intersection_index[:x] : intersection_index[:x] - word_index
                starting_y_index = board_word.across? ? intersection_index[:y] + word_index : intersection_index[:y]
                direction = board_word.orthogonal_direction
                intersecting_indices << {x: starting_x_index, y: starting_y_index, direction: direction}
              end
            end
          end
        end
        intersecting_indices
      end

      def eliminate_bad_locations(word, locations)
        locations.reject do |possible_location|
          @words.any?{|board_word| board_word.conflicts_with?(word, possible_location)}
        end
      end

      class Word
        attr_accessor :value, :x, :y, :direction

        def initialize(value, x, y, direction)
          @value = value
          @x = x
          @y = y
          @direction = direction
        end

        def leftmost_point
          @x
        end

        def rightmost_point
          self.across? ? @x + @value.length - 1 : @x
        end

        def highest_point
          @y
        end

        def lowest_point
          self.across? ? @y : @y - @value.length + 1
        end

        def across?
          direction == 'across'
        end

        def orthogonal_direction
          self.across? ? 'down' : 'across'
        end

        def intersects?(word)
          if @direction == word.direction
            puts "Words run parallel to each other"
            false
          elsif self.across?
            leftmost_point <= word.leftmost_point && rightmost_point >= word.rightmost_point && highest_point <= word.highest_point && lowest_point >= word.lowest_point
          else
            leftmost_point >= word.leftmost_point && rightmost_point <= word.rightmost_point && highest_point >= word.highest_point && lowest_point <= word.lowest_point
          end  
        end

        def intersection_valid?(word, location)
          intersection_x_index = self.across? ? location[:x] : x
          intersection_y_index = self.across? ? y : location[:y]
          # make sure that there's actually an intersection at that point
          word_intersection_index = self.across? ? location[:y] - intersection_y_index : intersection_x_index - location[:x]
          self_intersection_index = self.across? ? intersection_x_index - self.leftmost_point : self.highest_point - intersection_y_index
          if word_intersection_index >= 0 && word_intersection_index < word.length && self_intersection_index >= 0 && self_intersection_index < self.value.length
            return self.value[self_intersection_index] == word[word_intersection_index]
          end
          return false
        end

        def conflicts_with?(word, location)
          other_direction = location[:direction]
          if other_direction == self.direction
            # in this case, any overlap in indices isn't ok, and any side by side giberrish is also not ok
            if self.across?
              # so in this case, we're ok as long as they're at least one full row apart
              return false if (location[:y] - self.y).abs > 1
              # if they are on the same y plane, just make sure that the x indices don't overlap
              return location[:x] > self.rightmost_point + 1 || location[:x] + word.length < self.leftmost_point - 1
            else
              # in this case, we're golden as long as they have different x indexes
              return false if (location[:x] - self.x).abs > 1
              # otherwise make sure the indices don't overlap
              return location[:y] - word.length > self.highest_point + 1 || location[:y] < self.lowest_point - 1
            end
          else
            # in this case we need to make sure that there are no incorrect intersections and that the other word doesn't come right up to the side of this one.
            if self.across?
              other_highest_point = location[:y]
              other_lowest_point = location[:y] - word.length
              return false if other_lowest_point > self.highest_point + 1 || other_highest_point < self.lowest_point - 1
              # if we make it this far, we need to check for intersections
              return !intersection_valid?(word, location)
            else
              other_leftmost_point = location[:x]
              other_rightmost_point = location[:x] + word.length
              return false if other_leftmost_point > self.rightmost_point + 1 || other_rightmost_point < self.leftmost_point - 1
              return !intersection_valid?(word, location)
            end
          end
        end

        def coordinates_at_index(i)
          if self.across?
            { x: x + i, y: y }
          else
            { x: x, y: y - i }
          end
        end
      end
  end
end

