#!/usr/bin/env ruby

require 'fileutils'
require 'digest'
require 'optparse'
require 'set'
require 'colorize'

class Options
  def self.parse(args)
    options = { silent: false, exclude: [] }

    OptionParser.new do |opts|
      opts.banner = "Usage: dircheck PATH [options]"

      opts.on("-s", "--silent",
              "Suppress output if no changes are found.") do
        options[:silent] = true
      end

      opts.on("-e", "--exclude x,y,z", Array,
              "Exclude file extensions.") do |arr|
        options[:exclude] = arr
      end

      opts.on("-M", "--maxsize INTEGER", Integer,
              "Specify maximum file size to consider.") do |size|
        options[:maxsize] = size
      end
    end.parse!(args)
    options
  end
end



class DirChecker
  DB_FILE = File.expand_path '~/.dircheck'

  attr_reader :check_path, :options

  def initialize(path, options={})
    @check_path = path
    @options = options
  end

  def check!
    old_hashes = load_hashes
    old_paths = Set.new(old_hashes.keys)
    new_paths = Set.new(get_file_paths)
    new_hashes = (old_paths + new_paths).inject({}) do |hashes, p|
      next hashes if excluded?(p)
      if new_paths.include?(p)
        next hashes if maxsize && File.size(p) > maxsize

        hash = compute_hash(p)
        if old_hash = old_hashes[p]
          if hash == old_hash
            puts "  #{p}" unless silent?
          else
            puts "* #{p}".yellow
          end
        else
          puts "+ #{p}".green
        end

        hashes[p] = hash
        next hashes
      else
        puts "- #{p}".red
      end

      next hashes
    end

    dump_hashes(new_hashes)
  end

  private

  def db_file
    @db_file ||= "#{File.expand_path(check_path)}/.dircheck"
  end

  def compute_hash(path)
    Digest::MD5.file(path).hexdigest
  end

  def load_hashes
    FileUtils.touch(db_file)
    File.open(db_file).each_line.inject({}) do |hashes, line|
      hash, name = line.chomp.split
      hashes[name] = hash
      hashes
    end
  end

  def dump_hashes(hashes)
    File.open(db_file, "w") do |f|
      hashes.each do |path, hash|
        f.puts("#{hash} #{path}")
      end
    end
  end

  def get_file_paths
    Dir.chdir(check_path)
    Dir.glob("#{Dir.pwd}/**/*").reject { |p| File.directory?(p) }
  end

  def silent?
    options[:silent]
  end

  def excluded?(file)
    (options[:exclude] || []).any? do |pattern|
      File.fnmatch(pattern, file)
    end
  end

  def maxsize
    options[:maxsize]
  end
end


options = Options.parse(ARGV)

unless path = ARGV.shift
  raise OptionParser::MissingArgument.new("PATH")
end

raise Errno::ENOTDIR.new(path) unless File.directory?(path)

DirChecker.new(path, options).check!

