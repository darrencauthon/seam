require 'active_support/all'
require 'active_support/time'
require 'securerandom'
require 'json'
require_relative 'seam/worker'
Dir[File.dirname(__FILE__) + '/seam/*.rb'].each {|file| require file }

module Seam

  def self.steps_to_run
    Seam::Persistence.find_something_to_do
                       .group_by { |x| x.next_step }
                       .map      { |x| x[0] }
  end

end
