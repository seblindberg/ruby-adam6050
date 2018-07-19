# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Server do
  subject { ADAM6050::Server }

  let(:password)      { 'b6TSkfr6' }

  let(:login_msg)     { "$01PW0]\tklTYM\t\r" }
  let(:login_msg_inv) { "$01PW0\x0E\x0E\x0E\x0E\x0E\x0E\x0E\x0E\r" }

  let(:read_msg)      { "$016\r" }

  let(:write_msg)     { "#011201\r" }

  let(:port)          { 1025 }
  let(:server)        { subject.new password: password }
  let(:client) do
    UDPSocket.new.tap do |c|
      c.bind '127.0.0.1', 0
      c.connect '127.0.0.1', port
    end
  end

  before do
    @server_thread =
      Thread.new do
        Thread.abort_on_exception = true
        server.logger.level = Logger::FATAL
        server.run
      end
    # FIXME: ugly hack that allows the server to start
    sleep 0.1
  end

  after do
    @server_thread.kill
    sleep 0.01
  end

  describe 'login' do
    it 'allows the client to login given a valid password' do
      client.send login_msg, 0

      response, = client.recvfrom 8
      assert_equal ">01\r", response
    end

    it 'does not allow the client to login given an invalid password' do
      client.send login_msg_inv, 0
      response, = client.recvfrom 8
      assert_equal "?\r", response
    end
  end

  describe 'read' do
    it 'is not allowed when not logged in' do
      client.send read_msg, 0
      response, = client.recvfrom 8
      assert_equal "?\r", response
    end

    it 'is allowed when logged in' do
      client.send login_msg, 0
      client.recvfrom 8
      client.send read_msg, 0

      response, = client.recvfrom 64
      assert_equal "!01003FFFF\r", response
    end

    it 'returns the correct state' do
      client.send login_msg, 0
      client.recvfrom 8

      server.update { |state| ADAM6050::State.set_input state, 4, true }

      client.send read_msg, 0

      response, = client.recvfrom 64
      assert_equal "!01003FFEF\r", response
    end
  end

  describe 'write' do
    it 'is not allowed when not logged in' do
      client.send write_msg, 0
      response, = client.recvfrom 8
      assert_equal "?\r", response
    end

    it 'is allowed when logged in' do
      client.send login_msg, 0
      client.recvfrom 8
      client.send write_msg, 0

      response, = client.recvfrom 8
      assert_equal ">\r", response
    end

    it 'updates the state' do
      client.send login_msg, 0
      client.recvfrom 8
      client.send write_msg, 0

      sleep 0.01
      assert ADAM6050::State.output_set?(server.state, 2)
    end
  end
end
