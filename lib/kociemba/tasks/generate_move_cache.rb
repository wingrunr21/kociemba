# frozen_string_literal: true

require 'rake' unless defined? Rake
require 'kociemba/cache'

module Kociemba
  module Tasks
    module GenerateCache
      extend Rake::DSL

      namespace :kociemba do
        desc 'Generate move cache files'
        task :generate_cache do
        %i(
          FlipMove
          FrToBrMove
          TwistMove
          UbToDfMove
          UrToDfMove
          UrToUlMove
          UrfToDlfMove
          MergeUrToUlAndUbToDf
          SliceFlipPrune
          SliceTwistPrune
          SliceUrToDfParityPrune
          SliceUrfToDlfParityPrune
        ).each do |k|
            konst = Kociemba::Cache.const_get(k)
            puts "Dumping #{k}..."
            konst.dump
          end
        end
      end
    end
  end
end
