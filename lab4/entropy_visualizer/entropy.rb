#!/usr/bin/env ruby

require 'colorize'

BLOCK = '█'
COLORS = [:white, :magenta, :blue, :cyan, :green, :yellow, :red, :light_black]

def print_entropy(e)
  print color(e)
end

def color(e)
  BLOCK.public_send(COLORS[e.floor])
end

def entropy(bytes)
  freqs = Array.new(256, 0)

  bytes.each do |b|
    freqs[b] += 1
  end

  freqs.map! { |val| val.to_f / bytes.size }

  -freqs.inject(0.0) do |ent, freq|
    freq > 0 ? ent + freq * Math.log2(freq) : ent
  end
end


filename = ARGV.shift
block_size, offset, limit = ARGV.map(&:to_i)
offset ||= 0


f = File.open(filename, "rb")
f.seek(offset)

bytes = f.each_byte.lazy
bytes = bytes.take(limit) if limit
bytes.each_slice(block_size).each_with_index do |bytes, i|
  puts "\n>>> #{offset}" if i % 1000 == 0
  offset += block_size
  print_entropy entropy(bytes)
end

puts
