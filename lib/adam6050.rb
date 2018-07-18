# frozen_string_literal: true

require 'logger'
require 'socket'

require 'adam6050/error'
require 'adam6050/password'
require 'adam6050/session'
require 'adam6050/state'

require 'adam6050/handler'
require 'adam6050/handler/login'
require 'adam6050/handler/read'
require 'adam6050/handler/status'
require 'adam6050/handler/write'

require 'adam6050/server'

# This library implements a server that emulates the Advantech ADAM-6050 IO
# module.
module ADAM6050
end
