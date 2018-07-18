# frozen_string_literal: true

module ADAM6050
  # The server listens to a speciefied UDP port and delegates incomming messages
  # to the different handlers.
  class Server
    # @return [Integer] the dafault port of the UDP server.
    DEFAULT_PORT = 1025

    # @return [Logger] the logger used by the server.
    attr_reader :logger

    # @param  password [String] the plain text password to use when validating
    #   new clients.
    def initialize(password: nil, logger: Logger.new(STDOUT))
      @session  = Session.new
      @handlers = [
        Handler::Login.new(password),
        Handler::Status.new,
        Handler::Read.new,
        Handler::Write.new
      ]
      @state = State.initial
      @state_lock = Mutex.new
      @logger = logger
    end

    # @param  host [String] the host to listen on.
    # @param  port [Integer] the UDP port to listen on.
    def run(host: nil, port: DEFAULT_PORT, &block)
      logger.info "Listening on port #{port}"

      Socket.udp_server_loop host, port do |msg, sender|
        logger.debug { "#{sender.remote_address} -> '#{msg}'" }
        handler = @handlers.find { |h| h.handles? msg } || next

        @state_lock.synchronize do
          handle(handler, msg, sender, &block)
        end
      end
    end

    # Updates the state atomicly.
    def update
      @state_lock.synchronize do
        @state = yield @state
      end
    end

    private

    def handle(handler, msg, sender)
      @session.validate! sender if handler.validate?

      next_state, reply = handler.handle msg, @state, @session, sender
      
      if next_state != state
        commit = !block_given? || yield(next_state, @state)
        return if commit == false
      end

      sender.reply reply + "\r" if reply
      @state = next_state
    rescue Session::InvalidSender => e
      logger.warn e.message
    end
  end
end
