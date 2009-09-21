#
#  files_ds.rb
#  rudups
#
#  Created by Luis Parravicini on 9/6/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class FilesDS < ArrayDS
	include OSX

	def tableView_objectValueForTableColumn_row(table, col, row)
		col.dataCell.setBackgroundColor(NSColor.blueColor)
		@data[row].first if @data[row]
	end

	def <<(x)
		@data << x
		@data.sort_by { |r| r.last }
		notify
	end
end
