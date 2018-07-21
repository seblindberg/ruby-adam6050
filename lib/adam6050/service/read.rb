# frozen_string_literal: true

module ADAM6050
  module Service
    # Allows registed senders to read the state.
    #
    # From the manual:
    #   Name        Read Channel Status
    #   Description This command requests that the specified ADAM-6000 module
    #               return the status of its digital input channels.
    #   Syntax      #01C\r
    #   Response    !0100(data)(data)(data)(data)\r
    #               (data) a 2-character hexadecimal value representing the
    #               values of the digital input module.
    #
    # TODO: The manual clearly states that onlyt the status of the input
    #       channels should be included in the response. There are however
    #       examples out there that also include the output.
    #
    class Read
      include Service

      # @return [String] see Service::MESSAGE_PREAMBLE.
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
