# Crossword.rb

Crossword.rb is a ruby library for quick and easy crossword puzzle generation. It uses a branch and bound algorithm to quickly create compact and challenging puzzles. This library is still in the early stages of development. Contributions are welcome.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'crossword'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crossword

## Usage

```
puzzle = Crossword::Puzzle.new({word: 'The clue text to display here', next: 'Clue text for next word, etc'})
pdf = puzzle.generate_pdf # generates a pdf of the entire document
png = puzzle.generate_png # generates a png image of the crossword part
clues = puzzle.clue_text # returns the text used in the clues (including newlines)
word_bank = puzzle.word_bank # returns an array of all of the words in the puzzle
```

## Pdf options

TODO - fill out this section once the pdf generation code is done.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/crossword. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

