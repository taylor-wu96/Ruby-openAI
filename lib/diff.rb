require 'diffy'
require 'nokogiri'

def count_lines_from_html_diff(html)
  # Parse the HTML
  doc = Nokogiri::HTML(html)

  # Count changed lines (deletions and insertions)
  changed_lines = doc.css('.del, .ins').count

  # Count unchanged lines
  unchanged_lines = doc.css('.unchanged').count

  return changed_lines, unchanged_lines
end

def compare_documents(file1, file2, output_path)
  # Read files
  text1 = File.read(file1)
  text2 = File.read(file2)

  # Compare the files
  diff = Diffy::SplitDiff.new(text1, text2, :format => :html)

  # Create HTML report
  html_report = <<-HTML
  <html>
  <head>
    <style>
      .diff { overflow: auto; }
      .diff .del { background-color: #fbb6c2; } /* red for deletions */
      .diff .ins { background-color: #d4fcbc; } /* green for insertions */
      .col { width: 45%; }
      .container { display: flex; }
    </style>
  </head>
  <body>
    <div class="container">
        <div class="diff col">
            #{diff.left}
        </div>
        <div class="diff col">
            #{diff.right}
        </div>
    </div>
  </body>
  </html>
  HTML

  changed, unchanged = count_lines_from_html_diff(html_report)
  percentage_changed = unchanged.to_f / (changed + unchanged) * 100
  puts("Similarity: #{percentage_changed.round(2)} ")
  # Write to output file
  File.open(output_path, 'w') { |file| file.write(html_report) }
end

# Example usage
# compare_documents('homework_sample/HW2/student1.Rmd', 'homework_sample/HW2/student1_copy.Rmd', 'output/output.html')
