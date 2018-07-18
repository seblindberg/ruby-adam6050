# frozen_string_literal: true

require 'logger'
require 'socket'

require 'ADAM6050/version'

require 'ADAM6050/error'
require 'ADAM6050/password'
require 'ADAM6050/session'
require 'ADAM6050/state'

require 'ADAM6050/handler'
require 'ADAM6050/handler/login'
require 'ADAM6050/handler/read'
require 'ADAM6050/handler/status'
require 'ADAM6050/handler/write'

require 'ADAM6050/server'

# This library implements a server that emulates the Advantech ADAM-6050 IO
# module.
module ADAM6050
end
