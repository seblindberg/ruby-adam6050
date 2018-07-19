# frozen_string_literal: true

module ADAM6050
  module Handler
    # Allows senders to login.
    class Login
      include Handler

      # @return [String] see Handler::MESSAGE_PREAMBLE.
      MESSAGE_PREAMBLE = '$01PW'

      # @param  password [String] the plain text password to use when validating
      #   login requests. If no password is given every request will be granted.
      def initialize(password = nil)
        @password = Password.new password
        freeze
      end

      # @param  msg [String] the incomming message.
      # @param  state [Integer] the current state.
      # @param  session [Session] the current session.
      # @param  sender [Socket::UDPSource] the UDP client.
      #
      # @return [Integer] the next state (always unchanged).
      # @return [String] a reply. The reply is either '>01' or '?' depending on
      #   if the login attempt was successful or not.
      def handle(msg, state, session, sender)
        return state, '?' unless @password == msg[6..-1].chomp!

        session.register sender

        [state, '>01']
      end

      # @return [false] the login handler does not require the sender to be
      #   validated.
      def validate?
        false
      end
    end
  end
end
