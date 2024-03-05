# frozen_string_literal: true

require 'nokogiri'
require_relative 'chatgpt_api'

# Module to interact with OpenAI's API
module RubyOpenAI
  # Class for Plagiarism Checker
  class PlagiarismChecker
    def self.read_markdown_files(directory)
      Dir.glob("#{directory}/*.md").map do |file_path|
        content = File.read(file_path)
        [file_path, content]
      end
    end

    def self.extract_text_from_markdown(markdown)
      Nokogiri::HTML(markdown).text
    end

    def self.check_similarity(text1, text2)
      response = ChatGptAPI.send_message('I want you to act as a plagiarism checker.',
                                         "Determine the percentage of similarity for the following texts\nText 1: #{text1}\nText 2: #{text2}\n I want you to answer only with number, without text. Do not write explanations.")
      response['choices'][0]['message']['content']
    end

    def self.compare_files(files)
      files.combination(2).each do |file1, file2|
        text1 = extract_text_from_markdown(file1.last)
        text2 = extract_text_from_markdown(file2.last)

        result = check_similarity(text1, text2)
        puts "Comparing #{file1.first} and #{file2.first}: #{result}"
      end
    end
  end
end

# directory = 'homework_sample' # replace with your directory path
# markdown_files = RubyOpenAI::PlagiarismChecker.read_markdown_files(directory)
# RubyOpenAI::PlagiarismChecker.compare_files(markdown_files)
