# frozen_string_literal: true

require 'kociemba/cache/urf_to_dlf_move'

module Kociemba
  module Cache
    # Pruning table for the permutation of the corners and the UD-slice edges in phase2.
    # The pruning table entries give a lower estimation for the number of moves to reach the solved cube.
    class SliceUrfToDlfParityPrune < BasePrune
      def self.cache_name
        'slice_urf_to_dlf_parity_prune'.freeze
      end

      def self.dump
        size = N_SLICE2 * UrfToDlfMove::N_URF_TO_DLF * N_PARITY
        slice_urf_to_dlf_parity_prune = Array.new(size / 2, -1)
        depth = 0
        set_pruning(slice_urf_to_dlf_parity_prune, 0, 0)
        done = 1

        while done != size
          size.times do |i|
            parity = i % 2
            urf_to_dlf = (i / 2) / N_SLICE2
            slice = (i / 2) % N_SLICE2

            if get_pruning(slice_urf_to_dlf_parity_prune, i) == depth
              18.times do |j|
                if [3, 5, 6, 8, 12, 14, 15, 17].include? j
                  next
                else
                  new_slice = Cache.fr_to_br_move[slice][j]
                  new_urf_to_dlf = Cache.urf_to_dlf_move[urf_to_dlf][j]
                  new_parity = Cache.parity_move[parity][j]

                  new_size = (N_SLICE2 * new_urf_to_dlf + new_slice) * 2 + new_parity # FIXME: no idea if this is right
                  if get_pruning(slice_urf_to_dlf_parity_prune, new_size) == 0x0f
                    set_pruning(slice_urf_to_dlf_parity_prune, new_size, (depth + 1) & 0xff)
                    done += 1
                  end
                end
              end
            end
          end

          depth += 1
        end

        File.open(filename, 'w') {|f| JSON.dump(slice_urf_to_dlf_parity_prune, f)}
        slice_urf_to_dlf_parity_prune
      end
    end

    def self.slice_urf_to_dlf_parity_prune
      @slice_urf_to_dlf_parity_prune ||= SliceUrfToDlfParityPrune.load.freeze
    end
  end
end
