require 'tempfile'

Then('the greeting file on {string} should read {string}') do |service, expected|
  actual = Tempfile.create("#{service}-greeting.txt") do |file|
    Maze::Docker.copy_from_container(service, from: "/app/greeting.txt", to: file.path)

    # we have to read the file from its path as 'file.read' won't reflect the
    # changes from the copy command above
    File.read(file.path)
  end

  Maze.check.equal(expected, actual)
end

When('I copy the greeting file to {string}') do |service|
  Tempfile.create("#{service}-greeting.txt") do |file|
    file.write("hello friend")
    file.flush

    Maze::Docker.copy_to_container(service, from: file.path, to: "/app/greeting.txt")
  end
end
