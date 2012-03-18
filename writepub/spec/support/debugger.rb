# encoding: utf-8
module DebuggerHelper
  def let_me_debug
    require 'ruby-debug'
    debugger
  end
end