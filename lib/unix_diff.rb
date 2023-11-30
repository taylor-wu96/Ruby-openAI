require 'diffy'

# Function to read file content
def read_file(file_path)
  File.read(file_path)
rescue StandardError => e
  puts "Error reading file: #{e}"
  nil
end

# Paths to the files you want to compare
file1_path = 'homework_sample/HW2/student1.Rmd'
file2_path = 'homework_sample/HW2/student1_copy.Rmd'

# Read files
file1_content = read_file(file1_path)
file2_content = read_file(file2_path)

# Check if both files were read successfully
if file1_content && file2_content
  # Use Diffy to get the diff in HTML format
  diff = Diffy::Diff.new(file1_content, file2_content).to_s(:html)

  # Output the diff to an HTML file
  File.open('output/diff_output.html', 'w') { |file| file.write(diff) }

  puts 'Diff output has been saved to diff_output.html'
else
  puts 'Could not read one or both files.'
end
