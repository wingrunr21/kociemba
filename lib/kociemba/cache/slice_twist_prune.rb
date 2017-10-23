module Kociemba
  module Cache
    class SliceTwistPrune < BasePrune
      def self.cache_name
        'slice_twist_prune'.freeze
      end

      def self.dump
        size = N_SLICE1 * TwistMove::N_TWIST
        slice_twist_prune = Array.new(size / 2 + 1, -1)

        depth = 0
        set_pruning(slice_twist_prune, 0, 0)
        done = 1

        puts size
        while done != size
          puts done
          puts depth
          size.times do |i|
            twist = i / N_SLICE1
            slice = i % N_SLICE1

            if (get_pruning(slice_twist_prune, i) == depth)
              18.times do |j|
                new_slice = Cache.fr_to_br_move[slice * 24][j] # 24
                new_twist = Cache.twist_move[twist][j]

                new_size = N_SLICE1 * new_twist + new_slice # FIXME: no idea if this variable name is right

                if get_pruning(slice_twist_prune, new_size) == 0x0f
                  set_pruning(slice_twist_prune, new_size, (depth + 1) & 0xff)
                  done += 1
                end
              end
            end
          end
          depth += 1
        end

        File.open(filename, 'w') {|f| Marshal.dump(slice_twist_prune, f)}
        slice_twist_prune
      end
    end

    def self.slice_twist_prune
      @slice_twist_prune ||= SliceTwistPrune.load.freeze
    end
  end
end
