#
#  dup_finder_delegate.rb
#  rudups
#
#  Created by Luis Parravicini on 9/4/09.
#  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
#

module DupFinderDelegate
	def add_file(path, digest)
		@files_ds << [path, digest]
		@files_list.reloadData

		@export_btn.setEnabled(!@files_ds.empty?)
	end

	def finish_scanning(n)
		@progress_bar.setIndeterminate(false)
		@progress_bar.setMaxValue(n)
	end

	def process_file(fname)
		@progress_label.setStringValue("Reading #{File.basename(fname)}...")
		@progress_bar.incrementBy(1)
	end
	
	def finish
		@progress.close
		enable_controls
	end

	def start_scanning
		@progress_label.setStringValue("Scanning directories...")
	end

	def cancel
		@worker[:cancel] = true
	end
end
