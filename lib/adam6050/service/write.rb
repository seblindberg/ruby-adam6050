# frozen_string_literal: true

module ADAM6050
  module Service
    # Allows registed senders to change the output bits of the state.
    #
    # From the manual:
    #   Name        Write Digital Output
    #   Description This command sets a single or all digital output channels to
    #               the specific ADAM-6000 module.
    #   Syntax      #01bb(data)\r
    #               bb is used to indicate which channel(s) you want to set.
    #               Writing to all channels (write a byte): both characters
    #               should be equal to zero (BB=00).
    #               Writing to a single channel (write a bit): first character
    #               is 1, second character indicates channel number which can
    #               range from 0h to Fh.
    class Write
      include Service

      # @return [String] see Service::MESSAGE_PREAMBLE.
      MESSAGE_PREAMBLE = '#01'

      # @param  msg [String] the incomming message.
      # @param  state [Integer] the current state.
      # @return [Integer] the next state (always unchanged).
      # @return [String] the reply.
      def handle(msg, state, *)
        channel, value = parse msg
        next_state = if msg[3] == '1'
                       State.update state, channel, value
                     else
                       State.update_all state, value
                     end

        [next_state, '>']
      end

      private

      def parse(msg)
        [
          msg[4].to_i(16),
          msg[5..6].to_i(16)
        ]
      end
    end
  end
end
