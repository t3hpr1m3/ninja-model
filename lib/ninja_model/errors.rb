module NinjaModel
  class NinjaModelError < StandardError; end
  class AdapterNotSpecified < NinjaModelError; end
  class ConnectionTimeoutError < NinjaModelError; end
end
