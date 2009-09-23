#
#  ArrayDS.rb
#  rudups
#
#  Created by Luis Parravicini on 9/3/09.
#  Copyright (c) 2009 Luis Parravicini. All rights reserved.
#

require 'observer'

#
# Array Data Source
#
class ArrayDS < OSX::NSObject
	include Observable

	def initialize
		@data = []
	end

	def numberOfRowsInTableView(table)
		@data.size
	end

	def tableView_objectValueForTableColumn_row(table, col, row)
		@data[row]
	end

	def [](x)
		@data[x]
	end

	def include?(e)
		@data.include?(e)
	end
	
	def add_all(x)
		old_size = size
		x.each do |elem|
			@data << elem unless @data.include?(elem)
		end
		notify if size != old_size
	end

	def <<(x)
	    unless @data.include?(x)
			@data << x
			notify
		end
	end

	def each(&b)
		@data.each { |x| b.call(x) }
	end

	def map(&b)
		@data.map { |x| b.call(x) }
	end

	def size
		@data.size
	end

	def empty?
		@data.empty?
	end

	def compact!
		@data.compact!
		notify
	end

	def clear
		@data.clear
		notify
	end

	def nullify_at(i)
		@data[i] = nil
		notify
	end

	def notify
		changed
		notify_observers
	end
end
