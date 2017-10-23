require 'rake' unless defined? Rake
require 'kociemba/cache'

module Kociemba
  module Tasks
    module GenerateCache
      extend Rake::DSL

      namespace :kociemba do
        desc 'Generate move cache files'
        task :generate_cache do
          # %i(TwistMove FlipMove FrToBrMove UrfToDlfMove).each do |konst|
          #   move = Kociemba::MoveCache.const_get(konst)
          #   puts "Generating #{konst} cache..."
          #   move.dump
          # end
        end

        desc 'Remove all cache files'
        task :clear_cache do
          # Kociemba::Cache::
        end
      end
    end
  end
end
