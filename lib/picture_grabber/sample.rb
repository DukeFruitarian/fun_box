require File.join(File.dirname(__FILE__),"base/base")

url = ARGV[0]
dir_dest = ARGV[1] ? ARGV[1] : "all_pics"

PictureGrabber::Base.new.grab url, dir_dest
