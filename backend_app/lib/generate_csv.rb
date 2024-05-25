require 'csv'

module RubyOpenAI
  # Module to from json array to generate CSV files
  module GenerateCsv
    def self.generate_csv(data)
      headers = data.first.keys
      CSV.generate do |csv|
        csv << headers
        data.each do |row|
          csv << row.values
        end
      end
    end
  end
end
