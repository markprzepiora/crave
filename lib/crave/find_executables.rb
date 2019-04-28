require 'set'
require 'open3'

module Crave::FindExecutables
  def self.find_executables(cmd_or_cmds, where: nil)
    if where.nil?
      fail ArgumentError, '`where` must be a directory or an array of directories'
    end

    return to_enum(__callee__, cmd_or_cmds, where: where).lazy unless block_given?

    cmds = Array(cmd_or_cmds)
    where = Array(where).map do |dir|
      File.expand_path(dir)
    end.map do |dir|
      Dir.glob(dir)
    end.flatten(1).select do |dir|
      File.exists?(dir)
    end

    seen_paths = Set.new

    cmds.each do |cmd|
      which_a(cmd).each do |filepath|
        yield filepath unless seen_paths.include?(filepath)
        seen_paths << filepath
      end
    end

    find_files(*where).each do |filepath|
      next unless \
        cmds.include?(File.basename(filepath)) &&
        File.executable?(filepath) &&
        File.file?(filepath)
      yield filepath unless seen_paths.include?(filepath)
      seen_paths << filepath
    end
  end

  def self.which_a(cmd)
    system_out("which", "-a", cmd).lines.map(&:strip).lazy
  end

  def self.system_out(*args)
    Open3.capture2(*args).first
  end

  def self.find_files(*where)
    return to_enum(__callee__, *where).lazy unless block_given?

    Open3.popen2("find", *where, *%w( ( -type f -or -type l ) )) do |i, o, thread|
      o.each_line do |line|
        yield line.chomp
      end
    end
  end
end
