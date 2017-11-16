# frozen_string_literal: true

module Kociemba
  module Edge
    EDGE_SIZE = 2
    EDGES = %i(UR UF UL UB DR DF DL DB FR FL BL BR)
    EDGES.each_with_index {|e, i| const_set(e, i)}
  end
end
