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

def jaccard_similarity_with_bigrams(text1, text2)
  # Convert the texts into arrays of words.
  words1 = text1.split
  words2 = text2.split

  # Create bigrams (pairs of consecutive words).
  bigrams1 = words1.each_cons(2).to_set
  bigrams2 = words2.each_cons(2).to_set
  # Calculate the intersection and union of the bigrams.
  intersection = bigrams1.intersection(bigrams2).length.to_f
  union = bigrams1.union(bigrams2).length.to_f
  # Calculate Jaccard similarity.
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
def levenshtein_distance(str1, str2)
  # Handling the cases where one of the strings is empty
  return str1.length if str2.empty?
  return str2.length if str1.empty?

  m, n = str1.length, str2.length
  d = Array.new(m + 1) { Array.new(n + 1) }

  # Initialize the first row and column of the matrix
  (0..m).each { |i| d[i][0] = i }
  (0..n).each { |j| d[0][j] = j }

  # Fill in the matrix using dynamic programming
  (1..m).each do |i|
    (1..n).each do |j|
      cost = str1[i - 1] == str2[j - 1] ? 0 : 1
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
    csv << ["File 1", "File 2", "Jaccard Similarity", "Jaccard Similarity with Bigrams", "Cosine Similarity", "Overlap Coefficient", "Normalized Levenshtein Distance", "Normalized Hamming Distance"]

    files_content.keys.combination(2).each do |file1, file2|
      text1 = files_content[file1]
      text2 = files_content[file2]

      jaccard = jaccard_similarity(text1, text2)
      jaccard_with_bigrams = jaccard_similarity_with_bigrams(text1, text2).round(2)
      cosine = cosine_similarity(text1, text2)
      overlap = overlap_coefficient(text1, text2)
      levenshtein = 1 - normalized_levenshtein_distance(text1, text2)

      hamming = text1.length == text2.length ? 1 - normalized_hamming_distance(text1, text2).round(2) : "N/A"

      csv << [File.basename(file1), File.basename(file2), jaccard.round(2), jaccard_with_bigrams.round(2), cosine.round(2), overlap.round(2), levenshtein.round(2), hamming]
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
          jaccard_with_bigrams = jaccard_similarity_with_bigrams(text1, text2).round(2)
          cosine = cosine_similarity(text1, text2).round(2)
          overlap = overlap_coefficient(text1, text2).round(2)
          levenshtein = (1 - normalized_levenshtein_distance(text1, text2)).round(2)
          hamming = text1.length == text2.length ? (1 - normalized_hamming_distance(text1, text2)).round(2) : "N/A"

          # Concatenating all measures into a single string for the cell
          row << "J: #{jaccard}, JB: #{jaccard_with_bigrams}, C: #{cosine}, O: #{overlap}, L: #{levenshtein}, H: #{hamming}"
        end
      end
      csv << row
    end
  end
end

# Usage
folder_index = 2
directory = "homework_sample/HW#{folder_index}"
output_file = "output/plagiarism_results#{folder_index}.csv"
plagiarism_checker(directory, output_file)
# output_file = "output/comparison_matrix#{folder_index}.csv"
# create_comparison_matrix(directory, output_file)
