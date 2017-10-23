require 'kociemba/cubie_cube'
require 'json'
require 'kociemba/move_cube'

module Kociemba
  module Cache
    class BaseCache
      N_SLICE1 = 495  # 12 choose 4 possible positions of FR,FL,BL,BR edges
      N_SLICE2 = 24   # 4! permutations of FR,FL,BL,BR edges in phase2
      N_PARITY = 2    # 2 possible corner parities
      N_MOVE = 18

      # CACHE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'fixtures'))
      CACHE_DIR = File.expand_path(File.join(File.dirname(__FILE__), 'prunetables'))

      class << self
        def load
          # Marshal.load(File.binread(filename))
          JSON.parse(File.read("#{filename}.json"))
        end

        def cache_dir
          Dir.mkdir(CACHE_DIR) unless Dir.exist? CACHE_DIR
          CACHE_DIR
        end

        def filename
          File.join(cache_dir, cache_name)
        end
      end
    end

    class BasePrune < BaseCache
      # Set pruning value in table. Two values are stored in one byte
      def self.set_pruning(table, index, value)
        if (index & 1) == 0
          table[index / 2] &= 0xf0 | value
        else
          table[index / 2] &= 0x0f | (value << 4)
        end
      end

      # Extract pruning value
      def self.get_pruning(table, index)
        if (index & 1) == 0
          table[index / 2] & 0x0f
        else
          # FIXME: this begin could screw everything up
          begin
            (table[index / 2] & 0xf0) >> 4
          rescue
            -1
          end
        end
      end
    end
  end
end

Dir[File.expand_path(File.join(File.dirname(__FILE__), 'cache', '**', '*.rb'))].each {|f| require f}
