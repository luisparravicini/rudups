#
#  MainWindow.rb
#  rudups
#
#  Created by Luis Parravicini on 8/29/09.
#  Copyright (c) 2009 Luis Parravicini. All rights reserved.
#

require 'osx/cocoa'
require 'dup_finder_delegate'

class AppController < OSX::NSWindowController
	include OSX
	include DupFinderDelegate

	def awakeFromNib
		@dirs_ds = DirsDS.new
		@dirs_ds.add_observer(self)
		@dirs.setDataSource(@dirs_ds)
		@dirs.registerForDraggedTypes([NSFilenamesPboardType])

		@files_ds = FilesDS.new
		@files_list.setDataSource(@files_ds)

		# TODO i'm not sure this is the best place to put this
		Thread.abort_on_exception = true
	end

	def add_dirs(sender)
		dlg = NSOpenPanel.openPanel
		dlg.setCanChooseFiles(false)
		dlg.setCanChooseDirectories(true)
		dlg.setAllowsMultipleSelection(true)

		if NSFileHandlingPanelOKButton == dlg.runModal
			@dirs_ds.add_all dlg.filenames
			@dirs.reloadData
		end
	end

	# Observable notifications
	def update
		empty = @dirs_ds.empty?
		@go_btn.setEnabled(!empty)
		@remove_btn.setEnabled(!empty)
	end

	def remove_dirs(sender)
		@dirs.selectedRowIndexes.to_a.each { |i| @dirs_ds.nullify_at(i) }
		@dirs_ds.compact!
		@dirs.reloadData
	end

	def donate(sender)
		url = NSURL.alloc.initWithString("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=8493669")
		NSWorkspace.sharedWorkspace.openURL(url)
	end

	def find_dups(sender)
		@files_ds.clear
		disable_controls
		init_progress_bar(sender)

#		@worker.cancel if @worker
		@worker = Thread.new {
			finder = DupFinder.new(@dirs_ds)
			finder.delegate = self
			finder.main
		}
	end

	SEP = "# ===================="
	def export(sender)
		dlg = NSSavePanel.savePanel

		if NSFileHandlingPanelOKButton == dlg.runModal
			File.open(dlg.filename, 'w') do |f|
				f.puts <<EOT
# #{@files_ds.size} duplicates files found on:
#{@dirs_ds.map { |d| "# #{d}" }.join("\n")}
#
# using rudups on #{Time.now}
#
# each block of identical files is separated by a comment line like this:
#{SEP}
EOT
				last_digest = nil
				@files_ds.each do |row|
					path, digest = row

					last_digest = digest if last_digest.nil?
					if digest != last_digest
						last_digest = digest
						f.puts SEP
					end
					f.puts path
				end
			end
		end
	end

	def open_enclosing_folder(sender)
		dir = File.dirname(selected_file)
		NSWorkspace.sharedWorkspace.openFile(dir)
	end

	def open_file(sender)
		file = selected_file
		NSWorkspace.sharedWorkspace.openFile(file)
	end
	
	def send_to_trash(sender)
		file = selected_file
		idx = @files_list.selectedRowIndexes.to_a.first
		#TODO repeated code from remove_dir
		@files_ds.nullify_at(idx)
		@files_ds.compact!
		@files_list.reloadData
		#TODO check result
		NSWorkspace.sharedWorkspace.performFileOperation_source_destination_files_tag_(
			NSWorkspaceRecycleOperation, File.dirname(file), "", [File.basename(file)]) 
	end
	
	
	ib_action :add_dirs
	ib_action :remove_dirs
	ib_action :find_dups
	ib_action :export
	ib_action :cancel
	ib_action :donate
	ib_outlets :dirs
	#TODO there should be a ProgressController?
	ib_outlets :progress, :progress_label, :progress_bar
	ib_outlets :add_btn, :remove_btn, :go_btn, :export_btn
	ib_outlets :files_list
	# context menu
	ib_action :open_enclosing_folder
	ib_action :open_file
	ib_action :send_to_trash


	private

		def selected_file
			idx = @files_list.selectedRowIndexes.to_a.first
			@files_ds[idx].first
		end

		def disable_controls
			set_enabled_controls(false)
		end
		
		def set_enabled_controls(enabled)
			@dirs.setEnabled(enabled)
			@go_btn.setEnabled(enabled)
			@add_btn.setEnabled(enabled)
			@remove_btn.setEnabled(enabled)
		end

		def enable_controls
			set_enabled_controls(true)
		end

		def init_progress_bar(sender)
			@progress_label.setStringValue("Initializing...")
			@progress_bar.setIndeterminate(true)
			@progress_bar.startAnimation(self)
			@progress.makeKeyAndOrderFront(sender)
		end
end
