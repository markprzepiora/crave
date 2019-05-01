require 'crave'

module Crave::Serializers::DirenvSerializer
  def self.serialize_many(dependencies)
    dependencies.map do |dependency|
      serialize(dependency)
    end.join("\n") +
    "\n" +
    "# Finally, add the .bin directory to the path\n" +
    "PATH_add .bin\n"
  end

  def self.serialize(satisfied_dependency)
    env_string = satisfied_dependency.env.map do |key, value|
      "export #{key}=#{bash_quote(value)}\n"
    end.join

    paths_string = satisfied_dependency.prepend_paths.map do |path|
      "PATH_add #{bash_quote(path)}\n"
    end.join

    commands_string = satisfied_dependency.commands.map do |cmd|
      link_path = ".bin/#{cmd.name}"
      "ln -sf #{bash_quote(cmd.path)} #{bash_quote(link_path)}\n"
    end.join

    "# #{satisfied_dependency.name}\n" +
    env_string +
    paths_string +
    "mkdir -p .bin\n" +
    commands_string
  end

  def self.bash_quote(string)
    '"' +
    string.
      gsub('$', '\$').
      gsub('"', '\"').
      gsub('`', '\`').
      gsub('\\', '\\\\').
      gsub('!', '\!') +
    '"'
  end
  private_class_method :bash_quote
end
