require_relative '../crave'

class Crave::Command < Struct.new(:name, :path)
  def valid?
    File.exists?(path) && File.file?(path) && File.executable?(path)
  end

  def errors
    if valid?
      []
    else
      ["Command #{name} does not exist or is not executable at #{path}"]
    end
  end
end
