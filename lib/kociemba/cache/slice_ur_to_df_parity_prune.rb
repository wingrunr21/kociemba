module Kociemba
  module Cache
    class SliceUrToDfParityPrune < BasePrune
      def self.cache_name
        'slice_ur_to_df_parity_prune'.freeze
      end

      def self.dump
        size = N_SLICE2 * UrToDfMove::N_UR_TO_DF * N_PARITY
        slice_ur_to_df_parity_prune = Array.new(size / 2, -1)
        depth = 0
        set_pruning(slice_ur_to_df_parity_prune, 0, 0)
        done = 1

        while done != size
          size.times do |i|
            parity = i % 2
            ur_to_df = (i / 2) / N_SLICE2
            slice = (i / 2) % N_SLICE2

            if get_pruning(slice_ur_to_df_parity_prune, i) == depth
              18.times do |j|
                if [3, 5, 6, 8, 12, 14, 15, 17].include? j
                  next
                else
                  new_slice = Cache.fr_to_br_move[slice][j]
                  new_ur_to_df = Cache.ur_to_df_move[ur_to_df][j]
                  new_parity = Cache.parity_move[parity][j]

                  new_size = (N_SLICE2 * new_ur_to_df + new_slice) * 2 + new_parity # FIXME: no idea if this is right
                  if get_pruning(slice_ur_to_df_parity_prune, new_size) == 0x0f
                    set_pruning(slice_ur_to_df_parity_prune, new_size, (depth + 1) & 0xff)
                    done += 1
                  end
                end
              end
            end
          end

          depth += 1
        end

        File.open(filename, 'w') {|f| Marshal.dump(slice_ur_to_df_parity_prune, f)}
        slice_ur_to_df_parity_prune
      end
    end

    def self.slice_ur_to_df_parity_prune
      @slice_ur_to_df_parity_prune ||= SliceUrToDfParityPrune.load.freeze
    end
  end
end
