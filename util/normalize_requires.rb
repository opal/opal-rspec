require 'json'

REQ_FILE = 'opal/opal/rspec/requires.rb'
dependencies = JSON.parse(File.read(REQ_FILE))

def sort_by_hierarchy(input)
  input.sort do |a,b|
    # Put top level items first
    r = if a.count('/') < b.count('/')
      -1
    else
      a <=> b
    end
  end
end

corrected_paths = dependencies.map do |p|
  puts "Normalizing #{p}..."
  # Get our load paths consistent
  guesses = [p, "rspec/#{p}"]
  use = guesses.find do |g|
    $:.any? do |load_path_item|
      filename = File.join(load_path_item, g + '.rb')
      puts "Checking for #{filename}"
      File.exist? filename
    end
  end
  raise "Unable to find dependency #{p}, guessed with #{guesses}" unless use
  use  
end

# fix any cases we changed
as_tree = sort_by_hierarchy corrected_paths

File.open REQ_FILE, 'w' do |file|
  file << "# Generated automatically by util/normalize_requires.rb, triggered by Rake task :generate_requires, do not edit\n"
  as_tree.each do |p|        
    file << "require '#{p}'\n"
  end
end