require 'http'
require 'json'
include ConnectHttp
#module ConnectHttpで共通化。CTX:SSL証明

#ConnectAPIの呼出し
class ConnectapiController < ApplicationController
  
  # この↓一文がないとCSRF(Cross-Site Request Forgery)チェックでこけるので、APIをやりとりしているControllerには必要
  skip_before_filter :verify_authenticity_token
    
  #リフレッシュ
  def refresh
    txt = ""
    ConnectToken.find_each do |connect_token|
      connect_token.refresh
      txt = txt + connect_token.status.to_s
    end
    render :text => txt
  end
  
  
  
end
