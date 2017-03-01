puts "Committing..."
Dir.chdir(File.expand_path('../', __FILE__)) do
  system("git add --all .")
  system("git commit -m 'Update notes'")
  system("git push")
end