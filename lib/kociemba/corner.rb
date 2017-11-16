# frozen_string_literal: true

module Kociemba
  module Corner
    CORNER_SIZE = 3
    CORNERS = %i(URF UFL ULB UBR DFR DLF DBL DRB)
    CORNERS.each_with_index {|e, i| const_set(e, i)}
  end
end
