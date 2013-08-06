require File.expand_path(File.dirname(__FILE__) + '/../lib/seam')
require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'
require 'subtle'
require 'timecop'
require 'contrast'
require 'mocha/setup'

def test_moped_session
  session = Moped::Session.new([ "127.0.0.1:27017" ])
  session.use "seam_test"
end

Seam::Effort.set_session test_moped_session
