# frozen_string_literal: true

require 'set'
require 'matrix'
require 'csv'

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
  # creates a set of unique words. This means that duplicate words in text content are ignored.
  set1 = Set.new(text1.split)
  set2 = Set.new(text2.split)
  # Calculates the number of words common to both set1 and set2 (the intersection).
  intersection = set1.intersection(set2).length.to_f
  # Combines the words from both sets (the union), ensuring each word is unique in this combined set.
  union = set1.union(set2).length.to_f
  # Dividing the size of the intersection by the size of the union.
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

# Normalize Levenshtein Distance
def normalized_levenshtein_distance(text1, text2)
  max_length = [text1.length, text2.length].max
  levenshtein_distance(text1, text2).to_f / max_length
end

# Calculate Hamming Distance between two texts
def hamming_distance(str1, str2)
  raise 'Strings must be of equal length' unless str1.length == str2.length

  str1.chars.zip(str2.chars).count { |a, b| a != b }
end

# Normalize Hamming Distance
def normalized_hamming_distance(str1, str2)
  hamming_distance(str1, str2).to_f / str1.length
end

# Calculate Overlap Coefficient between two texts
def overlap_coefficient(text1, text2)
  set1 = Set.new(text1.split)
  set2 = Set.new(text2.split)
  intersection = set1.intersection(set2).length.to_f
  intersection / [set1.length, set2.length].min.to_f
end

def plagiarism_checker(directory, output_file)
  files_content = read_files(directory)

  CSV.open(output_file, 'w') do |csv|
    csv << ["File 1", "File 2", "Jaccard Similarity", "Cosine Similarity", "Overlap Coefficient", "Normalized Levenshtein Distance", "Normalized Hamming Distance"]

    files_content.keys.combination(2).each do |file1, file2|
      text1 = files_content[file1]
      text2 = files_content[file2]

      jaccard = jaccard_similarity(text1, text2)
      cosine = cosine_similarity(text1, text2)
      overlap = overlap_coefficient(text1, text2)
      levenshtein = 1 - normalized_levenshtein_distance(text1, text2)

      hamming = text1.length == text2.length ? 1 - normalized_hamming_distance(text1, text2).round(2) : "N/A"

      csv << [File.basename(file1), File.basename(file2), jaccard.round(2), cosine.round(2), overlap.round(2), levenshtein.round(2), hamming]
    end
  end
end

def create_comparison_matrix(directory, output_file)
  files_content = read_files(directory)
  file_names = files_content.keys.map { |file| File.basename(file) }

  CSV.open(output_file, "w") do |csv|
    # Creating the header
    csv << ['File / Method'] + file_names

    file_names.each do |file1|
      row = [file1]
      text1 = files_content[File.join(directory, file1)]

      file_names.each do |file2|
        text2 = files_content[File.join(directory, file2)]

        if file1 == file2
          # Fill diagonal with N/A
          row << 'N/A'
        else
          # Calculate and add each metric
          jaccard = jaccard_similarity(text1, text2).round(2)
          cosine = cosine_similarity(text1, text2).round(2)
          overlap = overlap_coefficient(text1, text2).round(2)
          levenshtein = (1 - normalized_levenshtein_distance(text1, text2)).round(2)
          hamming = text1.length == text2.length ? (1 - normalized_hamming_distance(text1, text2)).round(2) : "N/A"

          # Concatenating all measures into a single string for the cell
          row << "J: #{jaccard}, C: #{cosine}, O: #{overlap}, L: #{levenshtein}, H: #{hamming}"
        end
      end
      csv << row
    end
  end
end

# Usage
folder_index = 6
directory = "homework_sample/HW#{folder_index}"
output_file = "output/plagiarism_results#{folder_index}.csv"
plagiarism_checker(directory, output_file)
output_file = "output/comparison_matrix#{folder_index}.csv"
create_comparison_matrix(directory, output_file)
