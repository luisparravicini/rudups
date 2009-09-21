#
#  files_table.rb
#  rudups
#
#  Created by Luis Parravicini on 9/8/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class FilesTableView < OSX::NSTableView
	include OSX

	def menuForEvent(event)
		menuPoint = convertPoint_fromView(event.locationInWindow, nil)
		row = rowAtPoint(menuPoint)

		if row < numberOfRows && ! selectedRowIndexes.containsIndex(row)
			selectRowIndexes_byExtendingSelection(NSIndexSet.indexSetWithIndex(row), false)
		end

		NSMenu.popUpContextMenu_withEvent_forView(menu, event, self)
	end
end
