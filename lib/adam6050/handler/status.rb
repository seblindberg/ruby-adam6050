# frozen_string_literal: true

module ADAM6050
  module Handler
    # Allows registed senders to read the IO status.
    class Status
      include Handler

      # @return [String] see Handler::MESSAGE_PREAMBLE.
      MESSAGE_PREAMBLE = '$01C'

      # @param  msg [String] the incomming message.
      # @param  state [Integer] the current state.
      # @return [Array<Integer, String>] the next state and an optional reply.
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
