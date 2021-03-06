#
#  rb_main.rb
#  rudups
#
#  Created by Luis Parravicini on 8/29/09.
#  Copyright (c) 2009 Luis Parravicini. All rights reserved.
#

# TODO when creating a dmg the app on the dmg file cant find the required files
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'Frameworks/RubyCocoa.framework/Resources/ruby')

require 'osx/cocoa'

def rb_main_init
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  rbfiles = Dir.entries(path).select {|x| /\.rb\z/ =~ x}
  rbfiles -= [ File.basename(__FILE__) ]
  rbfiles.each do |path|
    require( File.basename(path) )
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
