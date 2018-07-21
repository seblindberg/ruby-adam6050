# frozen_string_literal: true

module ADAM6050
  # The server listens to a speciefied UDP port and delegates incomming messages
  # to the different services.
  class Server
    # @return [Integer] the dafault port of the UDP server.
    DEFAULT_PORT = 1025

    # @return [Logger] the logger used by the server.
    attr_reader :logger

    # @return [Integer] the current state.
    attr_reader :state

    # @param  password [String] the plain text password to use when validating
    #   new clients.
    # @param  logger [Logger] the logger to use.
    def initialize(password: nil, logger: Logger.new(STDOUT))
      @session  = Session.new
      @services = [
        Service::Login.new(password),
        Service::Status.new,
        Service::Read.new,
        Service::Write.new
      ]
      @state = State.initial
      @state_lock = Mutex.new
      @logger = logger
    end

    # Starts a new UDP server that listens on the given port. The state is
    # updated atomically and yielded to an optional block everytime a change is
    # made. By returning `false` the block can cancel the state update. This
    # call is blocking.
    #
    # @yield [Integer] the updated state.
    # @yield [Integer] the old state.
    #
    # @param  host [String] the host to listen on.
    # @param  port [Integer] the UDP port to listen on.
    # @return [nil]
    def run(host: nil, port: DEFAULT_PORT, &block)
      logger.info "Listening on port #{port}"

      Socket.udp_server_loop host, port do |msg, sender|
        logger.debug { "#{sender.remote_address.inspect} -> '#{msg.inspect}'" }
        service = @services.find { |s| s.handles? msg } || next
        @state_lock.synchronize do
          handle(service, msg, sender, &block)
        end
      end
      nil
    end

    # Updates the state atomicly. The current state will be yielded to the given
    # block and the return value used as the next state.
    #
    # @yield [Integer] the current state.
    def update
      @state_lock.synchronize do
        @state = yield @state
      end
    end

    private

    # @yield see #abort_state_change?
    #
    # @param  service [Service] the service selected to handle the message.
    # @param  msg [String] the received message.
    # @param  sender [UDPSource] the UDP client.
    # @param  block [Proc]
    # @return [nil]
    def handle(service, msg, sender, &block)
      @session.validate! sender if service.validate?

      next_state, reply = service.handle msg, @state, @session, sender

      return if abort_state_change?(next_state, &block)
      @state = next_state

      return unless reply

      sender.reply reply + "\r"
      logger.debug reply
    rescue Session::InvalidSender => e
      sender.reply "?\r"
      logger.warn e.message
    end

    # @yield [Integer] the next state.
    # @yield [Integer] the current state.
    #
    # @param  next_state [Integer] the next state.
    # @return [true] if the next state differ from the current and the
    #   (optional) given block returns `false`.
    # @return [false] otherwise.
    def abort_state_change?(next_state)
      return false if next_state == @state

      commit = !block_given? || yield(next_state, @state)
      commit == false
    end
  end
end
