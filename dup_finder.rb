#
#  DupFinder.rb
#  rudups
#
#  Created by Luis Parravicini on 8/31/09.
#  Copyright (c) 2009 Luis Parravicini. All rights reserved.
#

require 'digest/md5'
require 'find'

class DupFinder
	def initialize(dirs)
		@dirs = dirs.dup
	end
	attr_accessor :delegate
	
	def main
		if cancelled?
			@delegate.finish
			return
		end

		@delegate.start_scanning
		@hashes = Hash.new
		find_number_of_files

		@dirs.each do |dir|
			Find.find(dir) do |path|
				if cancelled?
					@delegate.finish
					return
				end
				next unless File.file?(path)

				@delegate.process_file(path)
				
				digest = hash_for(path)
				if @hashes.include?(digest)
					unless @hashes[digest] == :none
						@delegate.add_file(@hashes[digest], digest)
						@hashes[digest] = :none
					end

					@delegate.add_file(path, digest)
				else
					@hashes[digest] = path
				end
			end
		end

		@delegate.finish
	end

private
	def cancelled?
		Thread.current[:cancel]
	end

	def find_number_of_files
		n = 0
		@dirs.each do |dir|
			Find.find(dir) do |path|
				n += 1 if File.file?(path)
				return if cancelled?
			end
		end
		@delegate.finish_scanning(n)
	end

	#TODO benchmark this and check if it makes sense to do this in objc
	def hash_for(fname)
		digest = Digest::MD5.new

		File.open(fname) do |f|
			while (buf = f.read(4096)) do
				digest << buf
				return nil if cancelled?
			end
		end

		digest.hexdigest
	end

end
