require 'json'

REQ_FILE = 'opal/opal/rspec/requires.rb'
dependencies = JSON.parse(File.read(REQ_FILE))
corrected_paths = dependencies.reverse.map do |p|
  puts "Normalizing #{p}..."
  # Get our load paths consistent
  guesses = [p, "rspec/#{p}"]
  use = guesses.find do |g|
      begin
        require g
        true
      rescue LoadError
        false
      end
  end
  raise "Unable to find dependency #{p}, guessed with #{guesses}" unless use
  use  
end

puts 'Sorting by hierarchy'
as_tree = corrected_paths.sort do |a,b|
  # Put top level items first
  r = if a.count('/') < b.count('/')
    -1
  else
    a <=> b
  end
end

File.open REQ_FILE, 'w' do |file|
  file << "# Generated automatically, do not edit\n"
  as_tree.each do |p|        
    file << "require '#{p}'\n"
  end
end