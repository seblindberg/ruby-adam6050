# frozen_string_literal: true

module ADAM6050
  module Handler
    # Allows registed senders to read the IO status.
    #
    # I have so far not been able to find any documentation around this feature.
    # The meaning of the rely is therefore currently unknown.
    class Status
      include Handler

      # @return [String] see Handler::MESSAGE_PREAMBLE.
      MESSAGE_PREAMBLE = '$01C'

      # @param  msg [String] the incomming message.
      # @param  state [Integer] the current state.
      # @return [Integer] the next state (always unchanged).
      # @return [String] the reply.
      def handle(msg, state, *)
        reply =
          if msg == MESSAGE_PREAMBLE + "\r"
            '!01' + '000000000000' + '000000000000' + '000000000000'
          else
            '>'
          end

        [state, reply]
      end
    end
  end
end
