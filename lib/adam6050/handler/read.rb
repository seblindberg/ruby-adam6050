# frozen_string_literal: true

module ADAM6050
  module Handler
    # Allows registed senders to read the state.
    class Read
      include Handler

      # @return [String] see Handler::MESSAGE_PREAMBLE.
      MESSAGE_PREAMBLE = '$016'

      # @param  state [Integer] the current state.
      # @return [Integer] the next state (always unchanged).
      # @return [String] the reply.
      def handle(_, state, *)
        # From the manual:
        #   The first 2-character portion of the response (exclude the "!"
        #   character) indicates the address of the ADAM-6000 module. The second
        #   2-character portion of the response is reserved, and will always be
        #   00 currently.
        [state, '!0100' + State.to_bin(state)]
      end
    end
  end
end
