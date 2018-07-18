# frozen_string_literal: true

module ADAM6050
  # The session object is used by the server to keep track of authenticated
  # clients. Once a client is registered with the session it will be reported as
  # valid for a period of time, after which it is again marked as invalid and
  # needs to register again. Any activity before the timeout will reset the
  # countdown.
  #
  # == Usage
  # The following example creates a session with a 10 second timeout and
  # registers a sender. `#validate!` is then called at a later point in time to
  # verify that the sender is still valid.
  #
  #   session = Session.new timeout: 10.0
  #   session.register sender
  #
  #   # The following call will raise an exception if more
  #   # than 10 seconds has passed.
  #   session.validate! sender
  #
  class Session
    # @return [Numeric] the default number of seconds a sender is valid with no
    #   interaction.
    DEFAULT_TIMEOUT = 60.0

    # @return [Numeric] the default number of seconds to wait after one cleanup
    #   before perfoming the next.
    DEFAULT_CLEANUP_INTERVALL = 3600.0

    # The invalid sender error is used to signify that a sender is not
    # authenticated within the session. This can either be beacuse the sender
    # has not yet logged in, or beacuse an old login has expired.
    class InvalidSender < Error
      def initialize(sender)
        super "Invalid sender: #{sender}"
      end
    end

    # The unknown sender error is used to signify that a sender has not yet
    # authenticated within the session.
    class UnknownSender < InvalidSender; end

    # @param  timeout [Numeric] the number of seconds a sender is valid with no
    #   interaction.
    # @param  cleanup_interval [Numeric] the number of seconds to wait after one
    #   cleanup before perfoming the next.
    def initialize(timeout: DEFAULT_TIMEOUT,
                   cleanup_interval: DEFAULT_CLEANUP_INTERVALL)
      @session          = {}
      @timeout          = timeout
      @cleanup_interval = cleanup_interval
      @next_cleanup     = 0.0
    end

    # @return [Integer] the number of senders currently known by the session.
    #   Note that this may include invalid senders that have not yet been
    #   cleaned up.
    def size
      @session.size
    end

    # Register a new sender as valid in the current session.
    #
    # @param  sender [Socket::UDPSource] the udp client.
    # @param  time [Numeric] the current time. The current time will be used if
    #   not specified.
    # @return [nil]
    def register(sender, time: monotonic_timestamp)
      @session[session_key sender] = time
      nil
    end

    # A sender is valid as long as it is registered and has not expired within
    # the current session.
    #
    # @param  sender [Socket::UDPSource] the udp client.
    # @param  time [Numeric] the current time. The current time will be used if
    #   not specified.
    # @return [true] if the sender has authenticated and has been active within
    #   the configured timeout.
    # @return [false] otherwise.
    def valid?(sender, time: monotonic_timestamp)
      !expired? @session.fetch(session_key(sender), 0.0), time, @timeout
    end

    # Renews the given sender if it is still valid within the session and raises
    # an exception otherwise.
    #
    # @raise [UnknownSender] if the given sender is not registered.
    # @raise [InvalidSender] if the given sender is not valid.
    #
    # @param  sender [Socket::UDPSource] the udp client.
    # @param  time [Numeric] the current time. The current time will be used if
    #   not specified.
    # @return [nil]
    def validate!(sender, time: monotonic_timestamp)
      key = session_key sender
      last_observed = @session.fetch(key) { raise UnknownSender, sender }
      raise InvalidSender, sender if expired? last_observed, time, @timeout

      @session[key] = time
      nil
    end

    # Removes invalid senders from the session.
    #
    # @param  time [Numeric] the current time. The current time will be used if
    #   not specified.
    # @return [Numeric] the next time before which no cleanup will be performed.
    def cleanup!(time: monotonic_timestamp)
      return if time < @next_cleanup

      remove_expired! time, @timeout

      @next_cleanup = time + @cleanup_interval
    end

    private

    def session_key(sender)
      sender.remote_address.ip_address
    end

    def monotonic_timestamp
      Process.clock_gettime Process::CLOCK_MONOTONIC
    end

    def expired?(sess_time, time, timeout)
      threshold = time - timeout
      sess_time < threshold
    end

    def remove_expired!(time, timeout)
      @session.delete_if { |_, t| expired? t, time, timeout }
    end
  end
end
