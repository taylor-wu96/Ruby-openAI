# frozen_string_literal: true

require 'set'
require 'matrix'

# Read text from all files in a directory
def read_files(directory)
  files_content = {}
  Dir.glob("#{directory}/*").each do |file|
    next if File.directory?(file)

    files_content[file] = File.read(file).downcase.gsub(/[^a-z0-9\s]/i, '')
  end
  files_content
end

# Calculate Jaccard similarity between two texts
def jaccard_similarity(text1, text2)
  set1 = Set.new(text1.split)
  set2 = Set.new(text2.split)
  intersection = set1.intersection(set2).length.to_f
  union = set1.union(set2).length.to_f
  intersection / union
end

# Calculate Cosine similarity between two texts
def word_frequencies(text)
  freq = Hash.new(0)
  text.split.each { |word| freq[word] += 1 }
  freq
end

def cosine_similarity(text1, text2)
  freq1 = word_frequencies(text1)
  freq2 = word_frequencies(text2)

  common = freq1.keys & freq2.keys
  vectors = common.map { |f| [freq1[f], freq2[f]] }.transpose

  vec1 = Vector.elements(vectors.first)
  vec2 = Vector.elements(vectors.last)

  vec1.inner_product(vec2) / (vec1.magnitude * vec2.magnitude)
end

# Calculate Levenshtein Distance between two texts
def levenshtein_distance(s, t)
  return s.length if t.empty?
  return t.length if s.empty?

  m = s.length
  n = t.length
  d = Array.new(m + 1) { Array.new(n + 1) }

  (0..m).each { |i| d[i][0] = i }
  (0..n).each { |j| d[0][j] = j }

  (1..n).each do |j|
    (1..m).each do |i|
      cost = s[i - 1] == t[j - 1] ? 0 : 1
      d[i][j] = [d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost].min
    end
  end

  d[m][n]
end

# Calculate Hamming Distance between two texts
def hamming_distance(str1, str2)
  raise 'Strings must be of equal length' unless str1.length == str2.length

  str1.chars.zip(str2.chars).count { |a, b| a != b }
end

# Calculate Overlap Coefficient between two texts
def overlap_coefficient(text1, text2)
  set1 = Set.new(text1.split)
  set2 = Set.new(text2.split)
  intersection = set1.intersection(set2).length.to_f
  [set1.length, set2.length].min.to_f / intersection
end

# Main method to check plagiarism
# Updated plagiarism checker function
def plagiarism_checker(directory)
  files_content = read_files(directory)
  files_content.keys.combination(2).each do |file1, file2|
    text1 = files_content[file1]
    text2 = files_content[file2]

    jaccard = jaccard_similarity(text1, text2)
    cosine = cosine_similarity(text1, text2)
    overlap = overlap_coefficient(text1, text2)
    levenshtein = levenshtein_distance(text1, text2)

    puts "File 1: #{File.basename(file1)}, File 2: #{File.basename(file2)}"
    puts "Jaccard Similarity: #{jaccard.round(2)}"
    puts "Cosine Similarity: #{cosine.round(2)}"
    puts "Overlap Coefficient: #{overlap.round(2)}"
    puts "Levenshtein Distance: #{levenshtein}"

    if text1.length == text2.length
      hamming = hamming_distance(text1, text2)
      puts "Hamming Distance: #{hamming}"
    else
      puts 'Hamming Distance: Not Applicable (different lengths)'
    end

    puts "\n" # For better readability
  end
end

# Usage
directory = 'homework_sample'
plagiarism_checker(directory)
