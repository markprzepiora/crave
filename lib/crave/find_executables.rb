# typed: true

require 'crave'
require 'set'
require 'open3'
require 'sorbet-runtime'

module Crave::FindExecutables
  extend T::Sig

  sig{
    params(cmd_or_cmds: T.any(String, T::Array[String]), where: T.nilable(T::Array[String])).
    returns(T.untyped)
  }
  def self.find_executables(cmd_or_cmds, where: nil)
    to_enum(:each_executable, cmd_or_cmds, where: where).lazy
  end

  sig{
    params(
      cmd_or_cmds: T.any(String, T::Array[String]),
      where: T.nilable(T::Array[String]),
      block: T.proc.params(arg0: String).void,
    ).void
  }
  def self.each_executable(cmd_or_cmds, where: nil, &block)
    if where.nil?
      fail ArgumentError, '`where` must be a directory or an array of directories'
    end

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

    find_files(where) do |filepath|
      next unless \
        cmds.include?(File.basename(filepath)) &&
        File.executable?(filepath) &&
        File.file?(filepath)
      yield filepath unless seen_paths.include?(filepath)
      seen_paths << filepath
    end
  end

  sig{ params(cmd: String).returns(T::Array[String]) }
  def self.which_a(cmd)
    system_out("which", "-a", cmd).lines.map(&:strip)
  end

  sig{ params(args: String).returns(String) }
  def self.system_out(*args)
    T.unsafe(Open3).capture2(*args).first
  end

  sig{ params(where: T::Array[String], block: T.proc.params(arg0: String).void).void }
  def self.find_files(where, &block)
    T.unsafe(Open3).popen2("find", *where, *%w( ( -type f -or -type l ) )) do |i, o, thread|
      o.each_line do |line|
        yield line.chomp
      end
    end
  end
end
