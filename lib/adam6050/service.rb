# frozen_string_literal: true

module ADAM6050
  # Services are, for the most part, simple transformations that accept a
  # _state_, an incomming _message_, a _session_ and a _sender_ and produce a
  # new state as well as an optional reply. The only
  module Service
    # @return [String] the first letters of the message that should be used when
    #   determining if the handler can handle it.
    MESSAGE_PREAMBLE = '$01'

    # @param  msg [String] the incomming message.
    # @return [true] if the handler can handle the message.
    # @return [false] otherwise.
    def handles?(msg)
      msg.start_with? self.class::MESSAGE_PREAMBLE
    end

    # @return [true] if the handler requires the sender to be validated.
    def validate?
      true
    end
  end
end
