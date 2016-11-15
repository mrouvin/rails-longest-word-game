class GamingController < ApplicationController
  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    i = 0
    while i < grid_size
      grid << ("A".."Z").to_a.sample
      i += 1
    end
    grid # return an array
  end

  def game
    @grid = generate_grid(9)
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    start_time = params[:start_time]
    # @time = @end_time - @start_time
    attempt = params[:attempt].split("") #transforms string into array
    # params[:grid] est une string (de la requete)... a reconvertir en array
    grid = JSON.parse(params[:grid])
    run_game(attempt, grid, start_time, end_time)
  end

  def translate(word)
    systran_key = "02af5f47-3a73-4d4b-9a4e-81ca49cf8abb"
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{systran_key}&input=#{word}"
    systran_output = open(url).read
    JSON.parse(systran_output) # translation
  end

  def in_dictionary?(word)
    dictionary = File.read('/usr/share/dict/words').upcase.split("\n")
    dictionary.include?(word.upcase)
  end

  def word_to_hash(word) #array  => hash
    word_hash = {}
    word.each do |letter|
      if word_hash[letter].nil?
        word_hash[letter] = 1
      else
        word_hash[letter] += 1
      end
    end
    word_hash
  end

  def is_valid?(word, grid) # array and array
    word_to_hash(word).each do |key, count|
      return false if word_to_hash(grid).values[key] < count
    end
    true
  end

  def run_game(attempt, grid, start_time, end_time)
  # TODO: runs the game and return detailed hash of result
  word = attempt.map!(&:upcase) # returns an array
  # translation = translate(attempt)
    if !is_valid?(word, grid)
    @result = {
      score: 0,
      message: "it's not in the grid"
    }
  elsif is_same_word?(attempt, translation)
    @result = {
      score: 0,
      message: "not english"
    }
  else
    @result = {
      score: attempt.length.fdiv( end_time - start_time ),
      time: end_time - start_time,
      # translation: translation,
      message: "well done"
    }
  end
end
end
