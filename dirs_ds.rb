#
#  dirs_ds.rb
#  rudups
#
#  Created by Luis Parravicini on 9/7/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

class DirsDS < ArrayDS
	include OSX

	def tableView_validateDrop_proposedRow_proposedDropOperation(tableView, info, row, dropOperation)
		true
	end

	def tableView_acceptDrop_row_dropOperation(tableView, info, row, dropOperation)
		pboard = info.draggingPasteboard

		plist = pboard.dataForType(NSFilenamesPboardType)
		data, format, error = NSPropertyListSerialization.propertyListFromData_mutabilityOption_format_errorDescription(plist, NSPropertyListImmutable)
      #FIXME show error: die "Can't deserialize property list: #{error}" if data.nil?
		self.add_all data
		tableView.reloadData

		true
	end

end
