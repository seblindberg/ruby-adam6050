# frozen_string_literal: true

require 'test_helper'

describe ADAM6050::Server do
  subject { ADAM6050::Server }

  let(:password)      { 'b6TSkfr6' }
  let(:msg)           { "$01PW0]\tklTYM\t" }
  let(:msg_invalid)   { "$01PW0\x0E\x0E\x0E\x0E\x0E\x0E\x0E\x0E" }
  let(:addr)          { Addrinfo.ip('localhost') }
  let(:sender)        { Socket::UDPSource.new addr, addr }

  let(:server)        { subject.new password }
end
