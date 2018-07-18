# frozen_string_literal: true

module ADAM6050
  # The application state is stored as an integer an updated in an immutable
  # fashion. This module includes helper functions that simplify reading and
  # creating new states.
  module State
    # @return [Integer] the number of inputs.
    NUM_INPUTS  = 12

    # @return [Integer] the number of outputs.
    NUM_OUTPUTS = 6

    # @return [Integer] a binary mask selecting the bits of an integer used by
    #   the state.
    MASK = (1 << (NUM_INPUTS + NUM_OUTPUTS)) - 1

    INPUT_MASK = (1 << NUM_INPUTS) - 1
    OUTPUT_MASK = MASK - INPUT_MASK

    private_constant :MASK, :INPUT_MASK, :OUTPUT_MASK

    # @return [Integer] the initial state.
    def initial
      0
    end

    # @raise [RangeError] if the given channel index exceeds the number of
    #   available input channels.
    #
    # @param  state [Integer] the current state.
    # @param  input_channel [Integer] the input channel number.
    # @return [true, false] the state of the specified input.
    def input_set?(state, input_channel)
      raise RangeError if input_channel >= NUM_INPUTS

      state & (1 << input_channel) != 0
    end

    # @raise [RangeError] if the given channel index exceeds the number of
    #   available output channels.
    #
    # @param  state [Integer] the current state.
    # @param  output_channel [Integer] the output channel number.
    # @return [true, false] the state of the specified output.
    def output_set?(state, output_channel)
      raise RangeError if output_channel >= NUM_OUTPUTS

      state & (1 << output_channel + NUM_INPUTS) != 0
    end

    # @raise [RangeError] if the given channel index exceeds the number of
    #   available output channels.
    #
    # @param  state [Integer] the current state.
    # @param  output_channel [Integer] the output channel number.
    # @param  value [0,Integer] the value to update with.
    # @return [Integer] the next state.
    def update(state, output_channel, value)
      raise RangeError if output_channel >= NUM_OUTPUTS

      mask = (1 << output_channel + NUM_INPUTS)
      value.zero? ? state & ~mask : state | mask
    end

    # @param  state [Integer] the current state.
    # @param  values [Integer] the next output values.
    # @return [Integer] the next state.
    def update_all(state, values)
      state & INPUT_MASK | (values << NUM_INPUTS) & MASK
    end

    # @param  state [Integer] the current state.
    # @return [String] a string representation of the state.
    def inspect(state)
      compact = format '%018b', state
      compact[0...6] + ' ' + compact[6..-1]
    end

    # @param  state [Integer] the current state.
    # @return [String] a binary representation expected by the protocol.
    def to_bin(state)
      format '%05X', (~state & MASK)
    end

    module_function :initial, :input_set?, :output_set?, :update, :update_all,
                    :inspect, :to_bin
  end
end
